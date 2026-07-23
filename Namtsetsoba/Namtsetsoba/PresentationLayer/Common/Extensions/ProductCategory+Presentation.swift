import Foundation

extension ProductCategory {
    /// Emoji shown in category chips and map pins.
    var icon: String {
        switch self {
        case .bakery: "🍞"
        case .restaurant: "🍽️"
        case .grocery: "🛒"
        case .cafe: "☕"
        case .pastry: "🧁"
        }
    }
}
