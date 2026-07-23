import Foundation

/// Insert payload for the `baskets` table, built from a domain `NewBasket`.
struct ApiBasketInsert: Encodable {
    let storeId: UUID
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
        case storeId = "store_id"
        case originalPrice = "original_price"
        case discountedPrice = "discounted_price"
        case pickupStartTime = "pickup_start_time"
        case pickupEndTime = "pickup_end_time"
        case itemsDescription = "items_description"
        case remainingCount = "remaining_count"
    }

    init(from basket: NewBasket) {
        storeId = basket.storeId
        title = basket.title
        description = basket.description
        originalPrice = NSDecimalNumber(decimal: basket.originalPrice).doubleValue
        discountedPrice = NSDecimalNumber(decimal: basket.discountedPrice).doubleValue
        pickupStartTime = ISO8601DateCoding.string(from: basket.pickupStartTime)
        pickupEndTime = ISO8601DateCoding.string(from: basket.pickupEndTime)
        itemsDescription = basket.itemsDescription
        remainingCount = basket.remainingCount
    }
}
