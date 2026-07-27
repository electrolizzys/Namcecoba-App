import Foundation
import Supabase

/// Supabase-backed store ratings. A database trigger recomputes
/// `stores.rating` / `stores.rating_count` whenever rows change.
final class ApiRatingGateway: RatingGateway {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseClientProvider.client) {
        self.client = client
    }

    func submit(orderId: UUID, storeId: UUID, userId: UUID, stars: Int, comment: String?) async throws {
        let payload = ApiRatingInsert(
            orderId: orderId,
            storeId: storeId,
            userId: userId,
            stars: stars,
            comment: comment
        )
        // Upsert on order_id so re-rating replaces the previous value.
        try await client
            .from("ratings")
            .upsert(payload, onConflict: "order_id")
            .execute()
    }

    func fetchRatedOrderIds(userId: UUID) async throws -> Set<UUID> {
        let rows: [ApiRatedOrderRow] = try await client
            .from("ratings")
            .select("order_id")
            .eq("user_id", value: userId)
            .execute()
            .value
        return Set(rows.map(\.orderId))
    }
}
