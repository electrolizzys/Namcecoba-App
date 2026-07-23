import Foundation

/// Adds a store to a user's favourites.
protocol AddFavouriteStoreUseCase {
    func execute(userId: UUID, storeId: UUID) async throws
}

struct AddFavouriteStoreUseCaseImpl: AddFavouriteStoreUseCase {
    private let gateway: FavouriteGateway

    init(gateway: FavouriteGateway) {
        self.gateway = gateway
    }

    func execute(userId: UUID, storeId: UUID) async throws {
        try await gateway.add(userId: userId, storeId: storeId)
    }
}
