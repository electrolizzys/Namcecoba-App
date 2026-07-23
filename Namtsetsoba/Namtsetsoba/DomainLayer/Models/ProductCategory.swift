import Foundation

/// Business/product category a store belongs to.
///
/// Presentation concerns (emoji, colours) live in `ProductCategory+Presentation`.
enum ProductCategory: String, CaseIterable, Identifiable {
    case bakery = "Bakery"
    case restaurant = "Restaurant"
    case grocery = "Grocery"
    case cafe = "Cafe"
    case pastry = "Pastry"

    var id: String { rawValue }
}
