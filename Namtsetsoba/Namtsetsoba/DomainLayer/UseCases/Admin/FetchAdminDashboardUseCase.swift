import Foundation

protocol FetchAdminDashboardUseCase {
    func execute(period: SalesPeriod) async throws -> AdminDashboardStats
}

struct FetchAdminDashboardUseCaseImpl: FetchAdminDashboardUseCase {
    private let gateway: AdminGateway

    init(gateway: AdminGateway) {
        self.gateway = gateway
    }

    func execute(period: SalesPeriod) async throws -> AdminDashboardStats {
        try await gateway.fetchDashboardStats(period: period)
    }
}
