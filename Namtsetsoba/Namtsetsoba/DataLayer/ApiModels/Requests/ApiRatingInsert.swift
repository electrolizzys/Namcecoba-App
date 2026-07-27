import Foundation

/// Insert/upsert payload for the `ratings` table.
struct ApiRatingInsert: Encodable {
    let orderId: UUID
    let storeId: UUID
    let userId: UUID
    let stars: Int
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case stars, comment
        case orderId = "order_id"
        case storeId = "store_id"
        case userId = "user_id"
    }
}
