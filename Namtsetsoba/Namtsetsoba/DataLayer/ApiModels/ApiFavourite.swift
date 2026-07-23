import Foundation

/// API representation of a row in the `favourite_stores` table (read side).
struct ApiFavourite: Decodable {
    let storeId: UUID

    enum CodingKeys: String, CodingKey {
        case storeId = "store_id"
    }
}
