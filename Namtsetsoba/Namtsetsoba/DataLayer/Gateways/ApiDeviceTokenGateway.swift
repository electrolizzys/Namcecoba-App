import Foundation
import Supabase

/// Supabase-backed implementation of `DeviceTokenGateway`.
final class ApiDeviceTokenGateway: DeviceTokenGateway {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseClientProvider.client) {
        self.client = client
    }

    func upsert(userId: UUID, token: String) async throws {
        try await client
            .from("device_tokens")
            .upsert(
                ApiDeviceToken(userId: userId, token: token),
                onConflict: "user_id,token"
            )
            .execute()
    }

    func remove(userId: UUID, token: String) async throws {
        try await client
            .from("device_tokens")
            .delete()
            .eq("user_id", value: userId)
            .eq("token", value: token)
            .execute()
    }
}
