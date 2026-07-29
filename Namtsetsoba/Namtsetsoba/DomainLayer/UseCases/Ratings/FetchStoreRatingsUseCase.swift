import Foundation

/// Fetches customer ratings for a single store.
protocol FetchStoreRatingsUseCase {
    func execute(storeId: UUID) async throws -> [OrderRating]
}

struct FetchStoreRatingsUseCaseImpl: FetchStoreRatingsUseCase {
    private let gateway: RatingGateway

    init(gateway: RatingGateway) {
        self.gateway = gateway
    }

    func execute(storeId: UUID) async throws -> [OrderRating] {
        try await gateway.fetchRatings(storeId: storeId)
    }
}
