import Foundation
import Observation

/// App-wide presentation state shared across tabs.
///
/// Holds session/profile info plus cached orders, notifications and venue data.
/// All data access goes through injected use cases — this type never touches the
/// network or database directly.
@Observable
final class AppState {
    private static let favouritesKey = "favourite_store_ids"

    // MARK: - Dependencies

    @ObservationIgnored private let loadUserProfileUseCase: LoadUserProfileUseCase
    @ObservationIgnored private let fetchStoreUseCase: FetchStoreUseCase
    @ObservationIgnored private let fetchBusinessBasketsUseCase: FetchBusinessBasketsUseCase
    @ObservationIgnored private let fetchOrdersUseCase: FetchOrdersUseCase
    @ObservationIgnored private let fetchStoreOrdersUseCase: FetchStoreOrdersUseCase
    @ObservationIgnored private let fetchNotificationsUseCase: FetchNotificationsUseCase
    @ObservationIgnored private let markNotificationAsReadUseCase: MarkNotificationAsReadUseCase
    @ObservationIgnored private let markAllNotificationsAsReadUseCase: MarkAllNotificationsAsReadUseCase
    @ObservationIgnored private let fetchFavouriteStoreIdsUseCase: FetchFavouriteStoreIdsUseCase
    @ObservationIgnored private let addFavouriteStoreUseCase: AddFavouriteStoreUseCase
    @ObservationIgnored private let removeFavouriteStoreUseCase: RemoveFavouriteStoreUseCase

    // MARK: - State

    var currentRole: UserRole = .customer
    var isProfileReady = false
    var orders: [Order] = []
    var frequentStoreIds: Set<UUID> = [] {
        didSet { saveFavourites() }
    }

    var userEmail: String = ""
    var username: String = ""
    var userId: UUID?

    var notifications: [AppNotification] = []
    var unreadCount: Int { notifications.filter { !$0.isRead }.count }
    var pendingOrderNavigationId: UUID?

    var businessStore: Store = MockData.stores[0]
    var businessBaskets: [Basket] = MockData.businessBaskets
    var storeOrders: [Order] = []

    var basketRefreshTrigger = false

    // MARK: - Init

    init(container: AppContainer = .shared) {
        loadUserProfileUseCase = container.loadUserProfile
        fetchStoreUseCase = container.fetchStore
        fetchBusinessBasketsUseCase = container.fetchBusinessBaskets
        fetchOrdersUseCase = container.fetchOrders
        fetchStoreOrdersUseCase = container.fetchStoreOrders
        fetchNotificationsUseCase = container.fetchNotifications
        markNotificationAsReadUseCase = container.markNotificationAsRead
        markAllNotificationsAsReadUseCase = container.markAllNotificationsAsRead
        fetchFavouriteStoreIdsUseCase = container.fetchFavouriteStoreIds
        addFavouriteStoreUseCase = container.addFavouriteStore
        removeFavouriteStoreUseCase = container.removeFavouriteStore

        frequentStoreIds = Self.loadFavourites()
    }

    // MARK: - Session / profile

    @MainActor
    func loadUserInfo() async -> Bool {
        isProfileReady = false
        do {
            let profile = try await loadUserProfileUseCase.execute()
            userId = profile.id
            userEmail = profile.email
            username = profile.username
            currentRole = profile.role

            if profile.role == .business, let storeId = profile.storeId {
                if let store = try? await fetchStoreUseCase.execute(id: storeId) {
                    businessStore = store
                }
                businessBaskets = (try? await fetchBusinessBasketsUseCase.execute(storeId: storeId)) ?? []
            }

            await loadFavouriteStoresFromServer()
            isProfileReady = true
            return true
        } catch {
            print("⚠️ Could not load user info: \(error.localizedDescription)")
            isProfileReady = false
            return false
        }
    }

    @MainActor
    func loadOrders() async {
        guard let userId else { return }
        orders = (try? await fetchOrdersUseCase.execute(userId: userId)) ?? []
        if currentRole == .business {
            storeOrders = (try? await fetchStoreOrdersUseCase.execute(storeId: businessStore.id)) ?? []
        }
    }

    @MainActor
    func loadNotifications() async {
        guard let userId else { return }
        let limit = currentRole == .business ? 100 : 50
        notifications = (try? await fetchNotificationsUseCase.execute(userId: userId, limit: limit)) ?? []
    }

    @MainActor
    func markNotificationRead(_ notification: AppNotification) async {
        try? await markNotificationAsReadUseCase.execute(id: notification.id)
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }

    @MainActor
    func markAllNotificationsRead() async {
        guard let userId else { return }
        try? await markAllNotificationsAsReadUseCase.execute(userId: userId)
        for i in notifications.indices {
            notifications[i].isRead = true
        }
    }

    @MainActor
    func resetForSignOut() {
        isProfileReady = false
        currentRole = .customer
        userId = nil
        userEmail = ""
        username = ""
        orders = []
        notifications = []
        storeOrders = []
    }

    @MainActor
    func queueOrderNavigation(to orderId: UUID) {
        pendingOrderNavigationId = orderId
    }

    // MARK: - Favourites

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
                try? await addFavouriteStoreUseCase.execute(userId: uid, storeId: storeId)
            } else {
                try? await removeFavouriteStoreUseCase.execute(userId: uid, storeId: storeId)
            }
        }
    }

    @MainActor
    private func loadFavouriteStoresFromServer() async {
        guard currentRole == .customer || currentRole == .admin, let uid = userId else { return }
        if let ids = try? await fetchFavouriteStoreIdsUseCase.execute(userId: uid) {
            frequentStoreIds = ids
        }
    }

    // MARK: - Baskets / orders (local mutations)

    @MainActor
    func triggerBasketRefresh() {
        basketRefreshTrigger.toggle()
    }

    @MainActor
    func removeBasket(_ basket: Basket) {
        businessBaskets.removeAll { $0.id == basket.id }
    }

    // MARK: - Favourite persistence

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
}
