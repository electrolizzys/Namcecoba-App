import Foundation
import Supabase

/// Supabase-backed implementation of `NotificationGateway`.
final class ApiNotificationGateway: NotificationGateway {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseClientProvider.client) {
        self.client = client
    }

    func fetchNotifications(userId: UUID, limit: Int) async throws -> [AppNotification] {
        let rows: [ApiNotification] = try await client
            .from("notifications")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
        return rows.map { $0.toDomain() }
    }

    func markAsRead(id: UUID) async throws {
        try await client
            .from("notifications")
            .update(["is_read": true])
            .eq("id", value: id)
            .execute()
    }

    func markAllAsRead(userId: UUID) async throws {
        try await client
            .from("notifications")
            .update(["is_read": true])
            .eq("user_id", value: userId)
            .eq("is_read", value: false)
            .execute()
    }
}
