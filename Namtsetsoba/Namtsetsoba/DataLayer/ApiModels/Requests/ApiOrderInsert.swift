import Foundation

/// Insert payload for the `orders` table.
struct ApiOrderInsert: Encodable {
    let userId: UUID
    let basketId: UUID
    let status: String
    let pickupCode: String
    let totalPaid: Double

    enum CodingKeys: String, CodingKey {
        case status
        case userId = "user_id"
        case basketId = "basket_id"
        case pickupCode = "pickup_code"
        case totalPaid = "total_paid"
    }
}
