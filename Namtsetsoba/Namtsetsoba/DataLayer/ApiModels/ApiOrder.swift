import Foundation

/// API representation of a row in the `orders` table.
struct ApiOrder: Decodable {
    let id: UUID
    let userId: UUID?
    let basketId: UUID
    let status: String
    let pickupCode: String
    let totalPaid: Double
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, status
        case userId = "user_id"
        case basketId = "basket_id"
        case pickupCode = "pickup_code"
        case totalPaid = "total_paid"
        case createdAt = "created_at"
    }

    /// Maps the transport model to the domain `Order`, given its resolved `Basket`.
    func toDomain(basket: Basket) -> Order {
        Order(
            id: id,
            basket: basket,
            status: OrderStatus(rawValue: status) ?? .confirmed,
            pickupCode: pickupCode,
            orderDate: ISO8601DateCoding.date(from: createdAt),
            totalPaid: Decimal(totalPaid),
            userId: userId
        )
    }
}
