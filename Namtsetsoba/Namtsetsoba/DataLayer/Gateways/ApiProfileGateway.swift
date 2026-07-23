import Foundation
import Supabase

/// Supabase-backed implementation of `ProfileGateway`.
final class ApiProfileGateway: ProfileGateway {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseClientProvider.client) {
        self.client = client
    }

    func fetchProfile(userId: UUID) async throws -> UserProfile {
        let row: ApiProfile = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        return row.toDomain()
    }
}
