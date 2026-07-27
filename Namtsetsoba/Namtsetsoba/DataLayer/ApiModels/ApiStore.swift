import Foundation

/// API representation of a row in the `stores` table.
struct ApiStore: Decodable {
    let id: UUID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let category: String
    let rating: Double
    let ratingCount: Int?
    let openTime: String?
    let closeTime: String?
    let logoURL: String?

    enum CodingKeys: String, CodingKey {
        case id, name, address, latitude, longitude, category, rating
        case ratingCount = "rating_count"
        case openTime = "open_time"
        case closeTime = "close_time"
        case logoURL = "logo_url"
    }

    /// Maps the transport model to the domain `Store`.
    func toDomain() -> Store {
        Store(
            id: id,
            name: name,
            address: address,
            latitude: latitude,
            longitude: longitude,
            category: ProductCategory(rawValue: category) ?? .restaurant,
            rating: rating,
            openTime: openTime ?? "09:00",
            closeTime: closeTime ?? "21:00",
            logoURL: logoURL,
            ratingCount: ratingCount ?? 0
        )
    }
}
