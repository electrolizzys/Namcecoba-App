import Foundation
import Supabase

final class DeviceTokenService {
    static let shared = DeviceTokenService()
    private let db = supabase

    private init() {}

    struct DeviceTokenRow: Encodable {
        let userId: UUID
        let token: String
        let platform: String

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case token
            case platform
        }
    }

    func upsertToken(userId: UUID, token: String) async {
        do {
            try await db
                .from("device_tokens")
                .upsert(
                    DeviceTokenRow(userId: userId, token: token, platform: "ios"),
                    onConflict: "user_id,token"
                )
                .execute()
        } catch {
            print("⚠️ Failed to save device token: \(error.localizedDescription)")
        }
    }

    func removeToken(userId: UUID, token: String) async {
        do {
            try await db
                .from("device_tokens")
                .delete()
                .eq("user_id", value: userId)
                .eq("token", value: token)
                .execute()
        } catch {
            print("⚠️ Failed to remove device token: \(error.localizedDescription)")
        }
    }
}
