import Foundation

/// A placed order for a `Basket`.
struct Order: Identifiable, Hashable {
    let id: UUID
    let basket: Basket
    var status: OrderStatus
    let pickupCode: String
    let orderDate: Date
    let totalPaid: Decimal
    /// Customer who placed the order (from `orders.user_id`); may be nil for legacy rows.
    let userId: UUID?

    static func == (lhs: Order, rhs: Order) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
