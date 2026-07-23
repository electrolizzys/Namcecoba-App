import Foundation

/// Upsert payload for the `device_tokens` table.
struct ApiDeviceToken: Encodable {
    let userId: UUID
    let token: String
    let platform: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case token
        case platform
    }

    init(userId: UUID, token: String, platform: String = "ios") {
        self.userId = userId
        self.token = token
        self.platform = platform
    }
}
