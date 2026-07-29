import Foundation

/// Customer store-rating reads and writes.
protocol RatingGateway {
    /// Submits (or replaces) the rating for a picked-up order.
    func submit(orderId: UUID, storeId: UUID, userId: UUID, stars: Int, comment: String?) async throws
    /// Order ids the user has already rated, used to avoid prompting twice.
    func fetchRatedOrderIds(userId: UUID) async throws -> Set<UUID>
    /// All ratings left for a store (used by venue analytics).
    func fetchRatings(storeId: UUID) async throws -> [OrderRating]
}
