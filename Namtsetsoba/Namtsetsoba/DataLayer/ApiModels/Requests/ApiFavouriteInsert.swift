import Foundation

/// Insert payload for the `favourite_stores` table.
struct ApiFavouriteInsert: Encodable {
    let userId: UUID
    let storeId: UUID

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case storeId = "store_id"
    }
}
