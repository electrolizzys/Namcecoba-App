import Foundation
import Supabase

/// Supabase-backed implementation of `OrderGateway`.
final class ApiOrderGateway: OrderGateway {
    private let client: SupabaseClient
    private let basketGateway: BasketGateway

    init(
        client: SupabaseClient = SupabaseClientProvider.client,
        basketGateway: BasketGateway
    ) {
        self.client = client
        self.basketGateway = basketGateway
    }

    func createOrder(userId: UUID, basketId: UUID, totalPaid: Decimal, pickupCode: String) async throws {
        let insert = ApiOrderInsert(
            userId: userId,
            basketId: basketId,
            status: OrderStatus.confirmed.rawValue,
            pickupCode: pickupCode,
            totalPaid: NSDecimalNumber(decimal: totalPaid).doubleValue
        )
        try await client
            .from("orders")
            .insert(insert)
            .execute()
    }

    func fetchOrders(userId: UUID) async throws -> [Order] {
        let rows: [ApiOrder] = try await client
            .from("orders")
            .select()
            .eq("user_id", value: userId)
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

    func fetchStoreOrders(storeId: UUID) async throws -> [Order] {
        let basketRows: [ApiBasket] = try await client
            .from("baskets")
            .select()
            .eq("store_id", value: storeId)
            .execute()
            .value

        let basketIds = basketRows.map(\.id)
        guard !basketIds.isEmpty else { return [] }

        let storeRows: [ApiStore] = try await client
            .from("stores")
            .select()
            .eq("id", value: storeId)
            .execute()
            .value

        guard let store = storeRows.first?.toDomain() else { return [] }
        let basketMap = Dictionary(uniqueKeysWithValues: basketRows.map {
            ($0.id, $0.toDomain(store: store))
        })

        let rows: [ApiOrder] = try await client
            .from("orders")
            .select()
            .in("basket_id", values: basketIds.map(\.uuidString))
            .order("created_at", ascending: false)
            .execute()
            .value

        return rows.compactMap { row in
            guard let basket = basketMap[row.basketId] else { return nil }
            return row.toDomain(basket: basket)
        }
    }

    func updateStatus(orderId: UUID, status: OrderStatus) async throws {
        try await client
            .from("orders")
            .update(["status": status.rawValue])
            .eq("id", value: orderId)
            .execute()
    }
}
