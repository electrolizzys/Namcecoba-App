import Foundation

/// Fetches the orders a customer has placed.
protocol FetchOrdersUseCase {
    func execute(userId: UUID) async throws -> [Order]
}

struct FetchOrdersUseCaseImpl: FetchOrdersUseCase {
    private let gateway: OrderGateway

    init(gateway: OrderGateway) {
        self.gateway = gateway
    }

    func execute(userId: UUID) async throws -> [Order] {
        try await gateway.fetchOrders(userId: userId)
    }
}
