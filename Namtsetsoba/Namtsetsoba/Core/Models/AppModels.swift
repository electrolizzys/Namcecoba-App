import Foundation
import SwiftUI
import Observation

enum UserRole: String, Codable {
    case customer
    case business
}

// MARK: - Product Category

enum ProductCategory: String, CaseIterable, Identifiable {
    case bakery = "Bakery"
    case restaurant = "Restaurant"
    case grocery = "Grocery"
    case cafe = "Cafe"
    case pastry = "Pastry"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .bakery: "🍞"
        case .restaurant: "🍽️"
        case .grocery: "🛒"
        case .cafe: "☕"
        case .pastry: "🧁"
        }
    }
}

// MARK: - Sort Option

enum SortOption: String, CaseIterable, Identifiable {
    case price = "Price"
    case distance = "Distance"
    case topPicks = "Your Favorites"
    case bestDeal = "Best Deals"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .price: "banknote"
        case .distance: "location"
        case .topPicks: "heart.fill"
        case .bestDeal: "percent"
        }
    }
}

// MARK: - Store

struct Store: Identifiable, Hashable {
    let id: UUID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let category: ProductCategory
    let rating: Double
    let openTime: String
    let closeTime: String

    var isOpenNow: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let open = formatter.date(from: openTime),
              let close = formatter.date(from: closeTime) else { return true }

        let now = formatter.date(from: formatter.string(from: Date()))!
        return now >= open && now <= close
    }
}

// MARK: - Basket

struct Basket: Identifiable, Hashable {
    let id: UUID
    let store: Store
    let title: String
    let description: String
    let originalPrice: Decimal
    let discountedPrice: Decimal
    let pickupStartTime: Date
    let pickupEndTime: Date
    let itemsDescription: String
    let remainingCount: Int
    let distanceKm: Double?

    var savingsPercent: Int {
        let orig = NSDecimalNumber(decimal: originalPrice).doubleValue
        let disc = NSDecimalNumber(decimal: discountedPrice).doubleValue
        guard orig > 0 else { return 0 }
        return Int(((orig - disc) / orig) * 100)
    }

    static func == (lhs: Basket, rhs: Basket) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Order

enum OrderStatus: String, Codable {
    case confirmed
    case readyForPickup
    case pickedUp
    case cancelled

    var displayName: String {
        switch self {
        case .confirmed: "Confirmed"
        case .readyForPickup: "Ready for Pickup"
        case .pickedUp: "Picked Up"
        case .cancelled: "Cancelled"
        }
    }

    var color: Color {
        switch self {
        case .confirmed: .blue
        case .readyForPickup: .green
        case .pickedUp: .secondary
        case .cancelled: .red
        }
    }

    var systemImage: String {
        switch self {
        case .confirmed: "checkmark.circle.fill"
        case .readyForPickup: "bag.fill"
        case .pickedUp: "checkmark.seal.fill"
        case .cancelled: "xmark.circle.fill"
        }
    }
}

struct Order: Identifiable, Hashable {
    let id: UUID
    let basket: Basket
    var status: OrderStatus
    let pickupCode: String
    let orderDate: Date
    let totalPaid: Decimal

    static func == (lhs: Order, rhs: Order) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Shared App State

@Observable
final class AppState {
    private static let favouritesKey = "favourite_store_ids"

    var currentRole: UserRole = .customer
    var orders: [Order] = []
    var frequentStoreIds: Set<UUID> = [] {
        didSet { saveFavourites() }
    }

    var userEmail: String = ""
    var username: String = ""
    var userId: UUID?

    var businessStore: Store = MockData.stores[0]
    var businessBaskets: [Basket] = MockData.businessBaskets
    var storeOrders: [Order] = []

    init() {
        frequentStoreIds = Self.loadFavourites()
    }

    private func saveFavourites() {
        let strings = frequentStoreIds.map(\.uuidString)
        UserDefaults.standard.set(strings, forKey: Self.favouritesKey)
    }

    private static func loadFavourites() -> Set<UUID> {
        guard let strings = UserDefaults.standard.stringArray(forKey: favouritesKey) else {
            return MockData.frequentStoreIds
        }
        return Set(strings.compactMap { UUID(uuidString: $0) })
    }

    struct ProfileRow: Decodable {
        let id: UUID
        let username: String?
        let email: String?
        let role: String
        let storeId: UUID?

        enum CodingKeys: String, CodingKey {
            case id, username, email, role
            case storeId = "store_id"
        }
    }

    @MainActor
    func loadUserInfo() async {
        do {
            let user = try await supabase.auth.session.user
            userId = user.id
            userEmail = user.email ?? ""

            let profile: ProfileRow = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: user.id)
                .single()
                .execute()
                .value

            username = profile.username ?? ""

            if profile.role == "venue", let storeId = profile.storeId {
                currentRole = .business
                if let store = await StoreService.shared.fetchStore(id: storeId) {
                    businessStore = store
                }
                businessBaskets = await BasketService.shared.fetchBusinessBaskets(storeId: storeId)
            } else {
                currentRole = .customer
            }
        } catch {
            print("⚠️ Could not load user info: \(error.localizedDescription)")
        }
    }

    @MainActor
    func loadOrders() async {
        guard let userId else { return }
        orders = await OrderService.shared.fetchOrders(userId: userId)

        if currentRole == .business {
            storeOrders = await OrderService.shared.fetchStoreOrders(storeId: businessStore.id)
        }
    }

    func isFavourite(_ storeId: UUID) -> Bool {
        frequentStoreIds.contains(storeId)
    }

    func toggleFavourite(_ storeId: UUID) {
        if frequentStoreIds.contains(storeId) {
            frequentStoreIds.remove(storeId)
        } else {
            frequentStoreIds.insert(storeId)
        }
    }

    func placeOrder(for basket: Basket) -> Order {
        let code = String(format: "%04d", Int.random(in: 1000...9999))
        let order = Order(
            id: UUID(),
            basket: basket,
            status: .confirmed,
            pickupCode: code,
            orderDate: Date(),
            totalPaid: basket.discountedPrice
        )
        orders.insert(order, at: 0)
        frequentStoreIds.insert(basket.store.id)
        return order
    }

    func publishBasket(_ basket: Basket) {
        businessBaskets.insert(basket, at: 0)
    }

    func removeBasket(_ basket: Basket) {
        businessBaskets.removeAll { $0.id == basket.id }
    }
}
