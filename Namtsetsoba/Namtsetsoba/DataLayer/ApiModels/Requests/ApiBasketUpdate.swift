import Foundation

/// Update payload for the `baskets` table, built from a domain `BasketEdit`.
struct ApiBasketUpdate: Encodable {
    let title: String
    let description: String
    let originalPrice: Double
    let discountedPrice: Double
    let pickupStartTime: String
    let pickupEndTime: String
    let itemsDescription: String
    let remainingCount: Int

    enum CodingKeys: String, CodingKey {
        case title, description
        case originalPrice = "original_price"
        case discountedPrice = "discounted_price"
        case pickupStartTime = "pickup_start_time"
        case pickupEndTime = "pickup_end_time"
        case itemsDescription = "items_description"
        case remainingCount = "remaining_count"
    }

    init(from edit: BasketEdit) {
        title = edit.title
        description = edit.description
        originalPrice = NSDecimalNumber(decimal: edit.originalPrice).doubleValue
        discountedPrice = NSDecimalNumber(decimal: edit.discountedPrice).doubleValue
        pickupStartTime = ISO8601DateCoding.string(from: edit.pickupStartTime)
        pickupEndTime = ISO8601DateCoding.string(from: edit.pickupEndTime)
        itemsDescription = edit.itemsDescription
        remainingCount = edit.remainingCount
    }
}
