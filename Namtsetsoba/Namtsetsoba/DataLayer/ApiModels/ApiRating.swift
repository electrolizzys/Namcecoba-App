import Foundation

/// API representation of a row in the `ratings` table.
struct ApiRating: Decodable {
    let id: UUID
    let orderId: UUID
    let storeId: UUID
    let stars: Int
    let comment: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, stars, comment
        case orderId = "order_id"
        case storeId = "store_id"
        case createdAt = "created_at"
    }

    func toDomain() -> OrderRating {
        OrderRating(
            id: id,
            orderId: orderId,
            storeId: storeId,
            stars: stars,
            comment: comment,
            createdAt: ISO8601DateCoding.date(from: createdAt)
        )
    }
}

/// Lightweight projection used when we only need which orders were rated.
struct ApiRatedOrderRow: Decodable {
    let orderId: UUID

    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
    }
}
