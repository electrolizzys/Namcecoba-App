import Foundation

/// Removes a store from a user's favourites.
protocol RemoveFavouriteStoreUseCase {
    func execute(userId: UUID, storeId: UUID) async throws
}

struct RemoveFavouriteStoreUseCaseImpl: RemoveFavouriteStoreUseCase {
    private let gateway: FavouriteGateway

    init(gateway: FavouriteGateway) {
        self.gateway = gateway
    }

    func execute(userId: UUID, storeId: UUID) async throws {
        try await gateway.remove(userId: userId, storeId: storeId)
    }
}
