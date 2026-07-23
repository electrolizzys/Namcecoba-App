import Foundation

/// Fetches baskets currently available for customers to buy.
protocol FetchAvailableBasketsUseCase {
    func execute() async throws -> [Basket]
}

struct FetchAvailableBasketsUseCaseImpl: FetchAvailableBasketsUseCase {
    private let gateway: BasketGateway

    init(gateway: BasketGateway) {
        self.gateway = gateway
    }

    func execute() async throws -> [Basket] {
        try await gateway.fetchAvailableBaskets()
    }
}
