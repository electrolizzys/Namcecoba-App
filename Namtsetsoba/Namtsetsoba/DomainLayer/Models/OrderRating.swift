import Foundation

/// A star rating a customer left for a store after collecting an order.
struct OrderRating: Identifiable, Hashable {
    let id: UUID
    let orderId: UUID
    let storeId: UUID
    /// 1...5 stars.
    let stars: Int
    let comment: String?
    let createdAt: Date
}
