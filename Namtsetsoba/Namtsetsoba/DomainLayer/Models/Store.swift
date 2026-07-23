import Foundation

/// A partner venue that publishes surprise baskets.
struct Store: Identifiable, Hashable {
    let id: UUID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let category: ProductCategory
    let rating: Double
    let openTime: String
    let closeTime: String
    /// Public URL from Storage (`stores.logo_url`); shown on store list and offers when set.
    let logoURL: String?

    init(
        id: UUID,
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        category: ProductCategory,
        rating: Double,
        openTime: String,
        closeTime: String,
        logoURL: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.rating = rating
        self.openTime = openTime
        self.closeTime = closeTime
        self.logoURL = logoURL
    }

    /// Whether the venue is open at the current wall-clock time.
    var isOpenNow: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let open = formatter.date(from: openTime),
              let close = formatter.date(from: closeTime) else { return true }

        let now = formatter.date(from: formatter.string(from: Date()))!
        return now >= open && now <= close
    }
}
