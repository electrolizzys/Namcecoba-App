import Foundation

/// Favourite-store membership for a user.
protocol FavouriteGateway {
    func fetchStoreIds(userId: UUID) async throws -> Set<UUID>
    func add(userId: UUID, storeId: UUID) async throws
    func remove(userId: UUID, storeId: UUID) async throws
}
