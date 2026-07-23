import Foundation

/// Fetches the set of store ids a user has favourited.
protocol FetchFavouriteStoreIdsUseCase {
    func execute(userId: UUID) async throws -> Set<UUID>
}

struct FetchFavouriteStoreIdsUseCaseImpl: FetchFavouriteStoreIdsUseCase {
    private let gateway: FavouriteGateway

    init(gateway: FavouriteGateway) {
        self.gateway = gateway
    }

    func execute(userId: UUID) async throws -> Set<UUID> {
        try await gateway.fetchStoreIds(userId: userId)
    }
}
