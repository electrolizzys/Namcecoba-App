import Foundation

/// Advances an order to a new lifecycle status.
protocol UpdateOrderStatusUseCase {
    func execute(orderId: UUID, status: OrderStatus) async throws
}

struct UpdateOrderStatusUseCaseImpl: UpdateOrderStatusUseCase {
    private let gateway: OrderGateway

    init(gateway: OrderGateway) {
        self.gateway = gateway
    }

    func execute(orderId: UUID, status: OrderStatus) async throws {
        try await gateway.updateStatus(orderId: orderId, status: status)
    }
}
