import Foundation

/// Fetches the active baskets belonging to a venue.
protocol FetchBusinessBasketsUseCase {
    func execute(storeId: UUID) async throws -> [Basket]
}

struct FetchBusinessBasketsUseCaseImpl: FetchBusinessBasketsUseCase {
    private let gateway: BasketGateway

    init(gateway: BasketGateway) {
        self.gateway = gateway
    }

    func execute(storeId: UUID) async throws -> [Basket] {
        try await gateway.fetchBusinessBaskets(storeId: storeId)
    }
}
