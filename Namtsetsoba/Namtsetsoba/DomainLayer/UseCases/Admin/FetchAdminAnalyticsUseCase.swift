import Foundation

protocol FetchAdminAnalyticsUseCase {
    func execute(period: SalesPeriod) async throws -> AdminAnalyticsSnapshot
}

struct FetchAdminAnalyticsUseCaseImpl: FetchAdminAnalyticsUseCase {
    private let gateway: AdminGateway

    init(gateway: AdminGateway) {
        self.gateway = gateway
    }

    func execute(period: SalesPeriod) async throws -> AdminAnalyticsSnapshot {
        try await gateway.fetchAnalytics(period: period)
    }
}
