import Foundation

/// Admin-only reads and store onboarding / edits.
protocol AdminGateway {
    func fetchDashboardStats(period: SalesPeriod) async throws -> AdminDashboardStats
    func fetchStoreSales(period: SalesPeriod) async throws -> [StoreSalesSummary]
    func fetchRecentOrders(limit: Int) async throws -> [Order]
    func fetchUsers() async throws -> [UserProfile]
    func fetchActiveOffers() async throws -> [Basket]
    func fetchAnalytics(period: SalesPeriod) async throws -> AdminAnalyticsSnapshot
    func createStoreWithVenue(_ draft: NewVenueOnboarding) async throws -> Store
    func updateStore(id: UUID, with edit: StoreEdit) async throws -> Store
}
