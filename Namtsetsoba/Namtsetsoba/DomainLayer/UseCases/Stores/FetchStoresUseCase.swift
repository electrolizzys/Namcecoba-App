import Foundation

/// Fetches all stores.
protocol FetchStoresUseCase {
    func execute() async throws -> [Store]
}

struct FetchStoresUseCaseImpl: FetchStoresUseCase {
    private let gateway: StoreGateway

    init(gateway: StoreGateway) {
        self.gateway = gateway
    }

    func execute() async throws -> [Store] {
        try await gateway.fetchStores()
    }
}
