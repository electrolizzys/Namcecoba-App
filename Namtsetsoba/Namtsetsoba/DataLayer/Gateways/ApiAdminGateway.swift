import Foundation
import Supabase

/// Supabase-backed admin reporting and store onboarding.
final class ApiAdminGateway: AdminGateway {
    private let client: SupabaseClient
    private let basketGateway: BasketGateway

    init(
        client: SupabaseClient = SupabaseClientProvider.client,
        basketGateway: BasketGateway
    ) {
        self.client = client
        self.basketGateway = basketGateway
    }

    func fetchDashboardStats(period: SalesPeriod) async throws -> AdminDashboardStats {
        let start = period.startDate()
        let orders = try await loadAllOrders()
        let inPeriod = orders.filter { $0.orderDate >= start }
        let pickedUp = inPeriod.filter { $0.status == .pickedUp }
        let cancelled = inPeriod.filter { $0.status == .cancelled }

        let revenue = pickedUp.reduce(Decimal.zero) { $0 + $1.totalPaid }
        let completed = pickedUp.count + cancelled.count
        let cancelRate = completed == 0 ? 0 : Double(cancelled.count) / Double(completed)

        let stores = try await fetchStoreRows()
        let offers = try await basketGateway.fetchAvailableBaskets()
        let customersWithPickup = try await uniqueCustomerCount(since: start)

        return AdminDashboardStats(
            period: period,
            pickedUpRevenue: revenue,
            platformCommission: PlatformEconomics.commission(from: revenue),
            storeIncome: PlatformEconomics.storeIncome(from: revenue),
            pickedUpOrderCount: pickedUp.count,
            cancelledOrderCount: cancelled.count,
            cancelRate: cancelRate,
            activeStoreCount: stores.count,
            activeOfferCount: offers.count,
            customersWithPickupCount: customersWithPickup
        )
    }

    func fetchStoreSales(period: SalesPeriod) async throws -> [StoreSalesSummary] {
        let start = period.startDate()
        let pickedUp = try await loadAllOrders()
            .filter { $0.status == .pickedUp && $0.orderDate >= start }

        var buckets: [UUID: (name: String, count: Int, revenue: Decimal)] = [:]
        for order in pickedUp {
            let store = order.basket.store
            var bucket = buckets[store.id] ?? (store.name, 0, 0)
            bucket.count += 1
            bucket.revenue += order.totalPaid
            buckets[store.id] = bucket
        }

        return buckets.map { storeId, value in
            StoreSalesSummary(
                storeId: storeId,
                storeName: value.name,
                orderCount: value.count,
                totalRevenue: value.revenue,
                platformCommission: PlatformEconomics.commission(from: value.revenue),
                storeIncome: PlatformEconomics.storeIncome(from: value.revenue)
            )
        }
        .sorted { $0.totalRevenue > $1.totalRevenue }
    }

    func fetchRecentOrders(limit: Int) async throws -> [Order] {
        Array(try await loadAllOrders().prefix(limit))
    }

    func fetchUsers() async throws -> [UserProfile] {
        try await fetchProfileRows()
            .sorted { $0.email.localizedCaseInsensitiveCompare($1.email) == .orderedAscending }
    }

    func fetchActiveOffers() async throws -> [Basket] {
        try await basketGateway.fetchAvailableBaskets()
            .sorted { $0.store.name.localizedCaseInsensitiveCompare($1.store.name) == .orderedAscending }
    }

    func fetchAnalytics(period: SalesPeriod) async throws -> AdminAnalyticsSnapshot {
        let start = period.startDate()
        let inPeriod = try await loadAllOrders().filter { $0.orderDate >= start }

        var counts: [OrderStatus: Int] = [:]
        for status in OrderStatus.allCases {
            counts[status] = 0
        }
        for order in inPeriod {
            counts[order.status, default: 0] += 1
        }

        let pickedUp = inPeriod.filter { $0.status == .pickedUp }
        let cancelled = inPeriod.filter { $0.status == .cancelled }
        let completed = pickedUp.count + cancelled.count
        let cancelRate = completed == 0 ? 0 : Double(cancelled.count) / Double(completed)

        let aov: Decimal
        if pickedUp.isEmpty {
            aov = 0
        } else {
            let sum = pickedUp.reduce(Decimal.zero) { $0 + $1.totalPaid }
            aov = sum / Decimal(pickedUp.count)
        }

        return AdminAnalyticsSnapshot(
            period: period,
            statusCounts: counts,
            cancelRate: cancelRate,
            repeatCustomerRate: try await repeatCustomerRate(since: start),
            averageOrderValue: aov
        )
    }

    func createStoreWithVenue(_ draft: NewVenueOnboarding) async throws -> Store {
        let request = AdminCreateVenueRequest(draft: draft)
        let response: AdminCreateVenueResponse = try await client.functions
            .invoke("admin-create-venue", options: FunctionInvokeOptions(body: request))
        return response.store.toDomain()
    }

    func updateStore(id: UUID, with edit: StoreEdit) async throws -> Store {
        let update = ApiStoreUpdate(edit)
        let row: ApiStore = try await client
            .from("stores")
            .update(update)
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .value
        return row.toDomain()
    }

    // MARK: - Private

    private func loadAllOrders() async throws -> [Order] {
        let rows: [ApiOrder] = try await client
            .from("orders")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value

        let baskets = try await basketGateway.fetchAllBaskets()
        let basketMap = Dictionary(uniqueKeysWithValues: baskets.map { ($0.id, $0) })

        return rows.compactMap { row in
            guard let basket = basketMap[row.basketId] else { return nil }
            return row.toDomain(basket: basket)
        }
    }

    private func fetchStoreRows() async throws -> [Store] {
        let rows: [ApiStore] = try await client
            .from("stores")
            .select()
            .order("name")
            .execute()
            .value
        return rows.map { $0.toDomain() }
    }

    private func fetchProfileRows() async throws -> [UserProfile] {
        let rows: [ApiProfile] = try await client
            .from("profiles")
            .select()
            .order("email")
            .execute()
            .value
        return rows.map { $0.toDomain() }
    }

    private func uniqueCustomerCount(since start: Date) async throws -> Int {
        let rows: [OrderUserRow] = try await client
            .from("orders")
            .select("user_id")
            .eq("status", value: OrderStatus.pickedUp.rawValue)
            .gte("created_at", value: Self.isoString(start))
            .execute()
            .value
        return Set(rows.map(\.userId)).count
    }

    private func repeatCustomerRate(since start: Date) async throws -> Double {
        let rows: [OrderUserRow] = try await client
            .from("orders")
            .select("user_id")
            .eq("status", value: OrderStatus.pickedUp.rawValue)
            .gte("created_at", value: Self.isoString(start))
            .execute()
            .value

        let grouped = Dictionary(grouping: rows, by: \.userId)
        guard !grouped.isEmpty else { return 0 }
        let repeaters = grouped.values.filter { $0.count >= 2 }.count
        return Double(repeaters) / Double(grouped.count)
    }

    private static func isoString(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: date)
    }
}

// MARK: - Transport helpers

private struct OrderUserRow: Decodable {
    let userId: UUID
    enum CodingKeys: String, CodingKey { case userId = "user_id" }
}

private struct AdminCreateVenueRequest: Encodable {
    struct StorePayload: Encodable {
        let name: String
        let address: String
        let latitude: Double
        let longitude: Double
        let category: String
        let rating: Double
        let openTime: String
        let closeTime: String

        enum CodingKeys: String, CodingKey {
            case name, address, latitude, longitude, category, rating
            case openTime = "open_time"
            case closeTime = "close_time"
        }
    }

    struct AccountPayload: Encodable {
        let email: String
        let password: String
        let username: String
    }

    let store: StorePayload
    let account: AccountPayload

    init(draft: NewVenueOnboarding) {
        store = StorePayload(
            name: draft.store.name,
            address: draft.store.address,
            latitude: draft.store.latitude,
            longitude: draft.store.longitude,
            category: draft.store.category.rawValue,
            rating: draft.store.rating,
            openTime: draft.store.openTime,
            closeTime: draft.store.closeTime
        )
        account = AccountPayload(
            email: draft.accountEmail,
            password: draft.temporaryPassword,
            username: draft.accountUsername
        )
    }
}

private struct AdminCreateVenueResponse: Decodable {
    let store: ApiStore
}
