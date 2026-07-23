import Foundation

/// Fetches a single store by id.
protocol FetchStoreUseCase {
    func execute(id: UUID) async throws -> Store?
}

struct FetchStoreUseCaseImpl: FetchStoreUseCase {
    private let gateway: StoreGateway

    init(gateway: StoreGateway) {
        self.gateway = gateway
    }

    func execute(id: UUID) async throws -> Store? {
        try await gateway.fetchStore(id: id)
    }
}
