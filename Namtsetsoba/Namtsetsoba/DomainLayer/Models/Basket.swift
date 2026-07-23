import Foundation

/// A surprise basket offered by a `Store` for a discounted price.
struct Basket: Identifiable, Hashable {
    let id: UUID
    let store: Store
    let title: String
    let description: String
    let originalPrice: Decimal
    let discountedPrice: Decimal
    let pickupStartTime: Date
    let pickupEndTime: Date
    let itemsDescription: String
    let remainingCount: Int
    let distanceKm: Double?

    /// Percentage saved versus the original price (0 when the original price is unknown).
    var savingsPercent: Int {
        let orig = NSDecimalNumber(decimal: originalPrice).doubleValue
        let disc = NSDecimalNumber(decimal: discountedPrice).doubleValue
        guard orig > 0 else { return 0 }
        return Int(((orig - disc) / orig) * 100)
    }

    static func == (lhs: Basket, rhs: Basket) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
