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

    func markSupportNotificationsRead(userId: UUID, conversationId: UUID?) async throws {
        if let conversationId {
            try await client
                .from("notifications")
                .update(["is_read": true])
                .eq("user_id", value: userId)
                .eq("type", value: NotificationType.support.rawValue)
                .eq("is_read", value: false)
                .eq("reference_id", value: conversationId)
                .execute()
        } else {
            try await client
                .from("notifications")
                .update(["is_read": true])
                .eq("user_id", value: userId)
                .eq("type", value: NotificationType.support.rawValue)
                .eq("is_read", value: false)
                .execute()
        }
    }

    func submitSupportRequest(message: String) async throws {
        struct Params: Encodable {
            let p_message: String
        }

        // Prefer a SECURITY DEFINER RPC (docs/support_setup.sql). Fall back to the
        // edge function if the RPC is not installed yet.
        do {
            try await client
                .rpc("submit_support_request", params: Params(p_message: message))
                .execute()
            return
        } catch {
            let ns = error as NSError
            let text = "\(error.localizedDescription) \(ns.domain) \(ns.userInfo)".lowercased()
            let looksMissing =
                text.contains("could not find")
                || text.contains("pgrst202")
                || text.contains("404")
                || text.contains("does not exist")
                || text.contains("schema cache")

            guard looksMissing else { throw error }

            struct Body: Encodable { let message: String }
            try await client.functions.invoke(
                "submit-support-request",
                options: FunctionInvokeOptions(body: Body(message: message))
            )
        }
    }
}
