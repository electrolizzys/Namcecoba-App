import Foundation

/// Fetches orders customers placed at a venue.
protocol FetchStoreOrdersUseCase {
    func execute(storeId: UUID) async throws -> [Order]
}

struct FetchStoreOrdersUseCaseImpl: FetchStoreOrdersUseCase {
    private let gateway: OrderGateway

    init(gateway: OrderGateway) {
        self.gateway = gateway
    }

    func execute(storeId: UUID) async throws -> [Order] {
        try await gateway.fetchStoreOrders(storeId: storeId)
    }
}
