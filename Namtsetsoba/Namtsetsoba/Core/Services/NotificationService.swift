import Foundation
import Supabase

final class NotificationService {
    static let shared = NotificationService()
    private let db = supabase

    private init() {}

    struct NotificationRow: Decodable {
        let id: UUID
        let userId: UUID
        let title: String
        let body: String
        let type: String
        let referenceId: UUID?
        let isRead: Bool
        let createdAt: String

        enum CodingKeys: String, CodingKey {
            case id, title, body, type
            case userId = "user_id"
            case referenceId = "reference_id"
            case isRead = "is_read"
            case createdAt = "created_at"
        }
    }

    func fetchNotifications(userId: UUID, limit: Int = 50) async -> [AppNotification] {
        do {
            let rows: [NotificationRow] = try await db
                .from("notifications")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .limit(limit)
                .execute()
                .value

            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            return rows.map { row in
                let date = isoFormatter.date(from: row.createdAt)
                    ?? ISO8601DateFormatter().date(from: row.createdAt)
                    ?? Date()

                return AppNotification(
                    id: row.id,
                    title: row.title,
                    body: row.body,
                    type: NotificationType(rawValue: row.type) ?? .order,
                    referenceId: row.referenceId,
                    isRead: row.isRead,
                    createdAt: date
                )
            }
        } catch {
            print("⚠️ Failed to fetch notifications: \(error.localizedDescription)")
            return []
        }
    }

    func markAsRead(id: UUID) async {
        do {
            try await db
                .from("notifications")
                .update(["is_read": true])
                .eq("id", value: id)
                .execute()
        } catch {
            print("⚠️ Failed to mark notification read: \(error.localizedDescription)")
        }
    }

    func markAllAsRead(userId: UUID) async {
        do {
            try await db
                .from("notifications")
                .update(["is_read": true])
                .eq("user_id", value: userId)
                .eq("is_read", value: false)
                .execute()
        } catch {
            print("⚠️ Failed to mark all read: \(error.localizedDescription)")
        }
    }
}
