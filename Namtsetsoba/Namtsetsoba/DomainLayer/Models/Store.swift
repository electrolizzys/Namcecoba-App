import Foundation

/// A partner venue that publishes surprise baskets.
struct Store: Identifiable, Hashable {
    let id: UUID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let category: ProductCategory
    /// Average of collected customer star ratings (1...5). Falls back to a seed value
    /// while the store has no ratings yet.
    let rating: Double
    /// Number of customer ratings that produced `rating`.
    let ratingCount: Int
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
        logoURL: String? = nil,
        ratingCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.rating = rating
        self.ratingCount = ratingCount
        self.openTime = openTime
        self.closeTime = closeTime
        self.logoURL = logoURL
    }

    /// Neutral empty store used as a non-optional default before a real store loads.
    static let placeholder = Store(
        id: UUID(),
        name: "",
        address: "",
        latitude: 0,
        longitude: 0,
        category: .restaurant,
        rating: 0,
        openTime: "09:00",
        closeTime: "21:00"
    )

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
