import Foundation

/// Removes a basket.
protocol DeleteBasketUseCase {
    func execute(id: UUID) async throws
}

struct DeleteBasketUseCaseImpl: DeleteBasketUseCase {
    private let gateway: BasketGateway

    init(gateway: BasketGateway) {
        self.gateway = gateway
    }

    func execute(id: UUID) async throws {
        try await gateway.delete(id: id)
    }
}
