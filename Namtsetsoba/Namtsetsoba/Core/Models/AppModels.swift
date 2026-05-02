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
    /// Public URL from Storage (`stores.logo_url`), shown on store list and offers when set.
    let logoURL: String?

    init(
        id: UUID,
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        category: ProductCategory,
        rating: Double,
        openTime: String,
        closeTime: String,
        logoURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.rating = rating
        self.openTime = openTime
        self.closeTime = closeTime
        self.logoURL = logoURL
    }

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

// MARK: - Notification

enum NotificationType: String {
    case order
    case favourite
}

struct AppNotification: Identifiable {
    let id: UUID
    let title: String
    let body: String
    let type: NotificationType
    let referenceId: UUID?
    var isRead: Bool
    let createdAt: Date

    /// Icons differ by order lifecycle (titles come from DB triggers).
    var systemImage: String {
        switch type {
        case .favourite:
            return "bag.heart.fill"
        case .order:
            let t = title.lowercased()
            if t.contains("cancelled") { return "xmark.circle.fill" }
            if t.contains("ready") { return "takeoutbag.and.cup.and.straw.fill" }
            if t.contains("picked") { return "checkmark.circle.fill" }
            if t.contains("new order") { return "bell.badge.fill" }
            return "bag.fill"
        }
    }

    var iconColor: Color {
        switch type {
        case .favourite:
            return Color(red: 0.92, green: 0.28, blue: 0.48)
        case .order:
            let t = title.lowercased()
            if t.contains("cancelled") { return .red }
            if t.contains("ready") { return DesignTokens.primaryGreen }
            if t.contains("picked") { return .secondary }
            if t.contains("new order") { return .orange }
            return .blue
        }
    }

    /// Order row whose title indicates cancellation (solid red icon in notification list).
    var isCancelledOrderNotification: Bool {
        type == .order && title.localizedCaseInsensitiveContains("cancelled")
    }

    var timeAgo: String {
        let interval = Date().timeIntervalSince(createdAt)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        return "\(Int(interval / 86400))d ago"
    }
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

    var notifications: [AppNotification] = []
    var unreadCount: Int { notifications.filter { !$0.isRead }.count }

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

            await loadFavouriteStoresFromServer()
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

    @MainActor
    func loadNotifications() async {
        guard let userId else { return }
        let limit = currentRole == .business ? 100 : 50
        notifications = await NotificationService.shared.fetchNotifications(userId: userId, limit: limit)
    }

    @MainActor
    func markNotificationRead(_ notification: AppNotification) async {
        await NotificationService.shared.markAsRead(id: notification.id)
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }

    @MainActor
    func markAllNotificationsRead() async {
        guard let userId else { return }
        await NotificationService.shared.markAllAsRead(userId: userId)
        for i in notifications.indices {
            notifications[i].isRead = true
        }
    }

    func isFavourite(_ storeId: UUID) -> Bool {
        frequentStoreIds.contains(storeId)
    }

    func toggleFavourite(_ storeId: UUID) {
        let adding = !frequentStoreIds.contains(storeId)
        if adding {
            frequentStoreIds.insert(storeId)
        } else {
            frequentStoreIds.remove(storeId)
        }

        guard let uid = userId else { return }
        Task {
            if adding {
                await FavouriteStoreService.shared.add(userId: uid, storeId: storeId)
            } else {
                await FavouriteStoreService.shared.remove(userId: uid, storeId: storeId)
            }
        }
    }

    @MainActor
    private func loadFavouriteStoresFromServer() async {
        guard currentRole == .customer, let uid = userId else { return }
        let ids = await FavouriteStoreService.shared.fetchStoreIds(userId: uid)
        frequentStoreIds = ids
    }

    var basketRefreshTrigger = false

    @MainActor
    func triggerBasketRefresh() {
        basketRefreshTrigger.toggle()
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

    @MainActor
    func removeBasket(_ basket: Basket) {
        businessBaskets.removeAll { $0.id == basket.id }
    }
}
