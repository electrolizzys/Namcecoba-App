import Foundation

extension ProductCategory {
    var icon: String {
        switch self {
        case .bakery: "🍞"
        case .restaurant: "🍽️"
        case .grocery: "🛒"
        case .cafe: "☕"
        case .pastry: "🧁"
        }
    }

    var localizedName: String {
        switch self {
        case .bakery: L(.categoryBakery)
        case .restaurant: L(.categoryRestaurant)
        case .grocery: L(.categoryGrocery)
        case .cafe: L(.categoryCafe)
        case .pastry: L(.categoryPastry)
        }
    }
}
