import Foundation

struct ApiStoreUpdate: Encodable {
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let category: String
    let rating: Double
    let openTime: String
    let closeTime: String

    enum CodingKeys: String, CodingKey {
        case name, address, latitude, longitude, category, rating
        case openTime = "open_time"
        case closeTime = "close_time"
    }

    init(_ edit: StoreEdit) {
        name = edit.name
        address = edit.address
        latitude = edit.latitude
        longitude = edit.longitude
        category = edit.category.rawValue
        rating = edit.rating
        openTime = edit.openTime
        closeTime = edit.closeTime
    }
}
