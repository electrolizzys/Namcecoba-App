import Foundation

/// API representation of a row in the `baskets` table.
struct ApiBasket: Decodable {
    let id: UUID
    let storeId: UUID
    let title: String
    let description: String?
    let originalPrice: Double
    let discountedPrice: Double
    let pickupStartTime: String
    let pickupEndTime: String
    let itemsDescription: String?
    let remainingCount: Int

    enum CodingKeys: String, CodingKey {
        case id, title, description
        case storeId = "store_id"
        case originalPrice = "original_price"
        case discountedPrice = "discounted_price"
        case pickupStartTime = "pickup_start_time"
        case pickupEndTime = "pickup_end_time"
        case itemsDescription = "items_description"
        case remainingCount = "remaining_count"
    }

    /// Maps the transport model to the domain `Basket`, given its resolved `Store`.
    func toDomain(store: Store) -> Basket {
        Basket(
            id: id,
            store: store,
            title: title,
            description: description ?? "",
            originalPrice: Decimal(originalPrice),
            discountedPrice: Decimal(discountedPrice),
            pickupStartTime: ISO8601DateCoding.date(from: pickupStartTime),
            pickupEndTime: ISO8601DateCoding.date(from: pickupEndTime),
            itemsDescription: itemsDescription ?? "",
            remainingCount: remainingCount,
            distanceKm: nil
        )
    }
}
