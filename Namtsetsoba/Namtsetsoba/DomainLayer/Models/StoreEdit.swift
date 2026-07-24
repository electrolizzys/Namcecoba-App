import Foundation

/// Editable store fields for admin updates.
struct StoreEdit: Hashable {
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var category: ProductCategory
    var openTime: String
    var closeTime: String
    var rating: Double
}
