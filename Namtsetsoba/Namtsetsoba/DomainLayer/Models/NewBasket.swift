import Foundation

/// Domain request describing a basket a venue wants to publish.
///
/// The data layer maps this to its API insert payload; the presentation layer
/// builds it from form input without knowing any transport details.
struct NewBasket {
    let storeId: UUID
    let title: String
    let description: String
    let originalPrice: Decimal
    let discountedPrice: Decimal
    let pickupStartTime: Date
    let pickupEndTime: Date
    let itemsDescription: String
    let remainingCount: Int
}
