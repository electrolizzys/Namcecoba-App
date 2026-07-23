import Foundation

/// API representation of a row in the `notifications` table.
struct ApiNotification: Decodable {
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

    /// Maps the transport model to the domain `AppNotification`.
    func toDomain() -> AppNotification {
        AppNotification(
            id: id,
            title: title,
            body: body,
            type: NotificationType(rawValue: type) ?? .order,
            referenceId: referenceId,
            isRead: isRead,
            createdAt: ISO8601DateCoding.date(from: createdAt)
        )
    }
}
