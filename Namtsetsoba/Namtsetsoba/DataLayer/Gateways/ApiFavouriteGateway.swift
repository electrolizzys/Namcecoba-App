import Foundation
import Supabase

/// Supabase-backed implementation of `FavouriteGateway`.
final class ApiFavouriteGateway: FavouriteGateway {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseClientProvider.client) {
        self.client = client
    }

    func fetchStoreIds(userId: UUID) async throws -> Set<UUID> {
        let rows: [ApiFavourite] = try await client
            .from("favourite_stores")
            .select("store_id")
            .eq("user_id", value: userId)
            .execute()
            .value
        return Set(rows.map(\.storeId))
    }

    func add(userId: UUID, storeId: UUID) async throws {
        try await client
            .from("favourite_stores")
            .insert(ApiFavouriteInsert(userId: userId, storeId: storeId))
            .execute()
    }

    func remove(userId: UUID, storeId: UUID) async throws {
        try await client
            .from("favourite_stores")
            .delete()
            .eq("user_id", value: userId)
            .eq("store_id", value: storeId)
            .execute()
    }
}
