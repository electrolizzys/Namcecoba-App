import Foundation

protocol FetchAdminOrdersUseCase {
    func execute(limit: Int) async throws -> [Order]
}

struct FetchAdminOrdersUseCaseImpl: FetchAdminOrdersUseCase {
    private let gateway: AdminGateway

    init(gateway: AdminGateway) {
        self.gateway = gateway
    }

    func execute(limit: Int = 100) async throws -> [Order] {
        try await gateway.fetchRecentOrders(limit: limit)
    }
}
