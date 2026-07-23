import Foundation

/// Publishes a new basket for a venue.
protocol CreateBasketUseCase {
    func execute(_ basket: NewBasket) async throws
}

struct CreateBasketUseCaseImpl: CreateBasketUseCase {
    private let gateway: BasketGateway

    init(gateway: BasketGateway) {
        self.gateway = gateway
    }

    func execute(_ basket: NewBasket) async throws {
        try await gateway.create(basket)
    }
}
