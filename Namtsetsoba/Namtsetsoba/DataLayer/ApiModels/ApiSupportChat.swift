import Foundation

/// Row from `support_conversations` joined with the user profile.
struct ApiSupportConversation: Decodable {
    let id: UUID
    let userId: UUID
    let lastMessagePreview: String?
    let lastMessageAt: String?
    let createdAt: String?
    let profile: ApiSupportProfile?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case lastMessagePreview = "last_message_preview"
        case lastMessageAt = "last_message_at"
        case createdAt = "created_at"
        case profile = "profiles"
    }

    func toDomain() -> SupportConversation {
        SupportConversation(
            id: id,
            userId: userId,
            userDisplayName: profile?.displayName ?? "User",
            userEmail: profile?.email ?? "",
            userRole: profile?.role ?? "customer",
            lastMessagePreview: lastMessagePreview,
            lastMessageAt: lastMessageAt.map { ISO8601DateCoding.date(from: $0) }
        )
    }
}

struct ApiSupportProfile: Decodable {
    let username: String?
    let email: String?
    let role: String?

    var displayName: String {
        if let username, !username.isEmpty { return username }
        if let email, !email.isEmpty { return email }
        return "User"
    }
}

struct ApiSupportMessage: Decodable {
    let id: UUID
    let conversationId: UUID
    let senderId: UUID
    let body: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, body
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case createdAt = "created_at"
    }

    func toDomain() -> SupportMessage {
        SupportMessage(
            id: id,
            conversationId: conversationId,
            senderId: senderId,
            body: body,
            createdAt: ISO8601DateCoding.date(from: createdAt)
        )
    }
}
