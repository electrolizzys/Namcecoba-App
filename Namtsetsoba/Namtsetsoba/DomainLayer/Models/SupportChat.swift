import Foundation

/// A support thread between one customer/venue user and Namtsetsoba admins.
struct SupportConversation: Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let userDisplayName: String
    let userEmail: String
    /// `customer` or `venue` (DB role).
    let userRole: String
    let lastMessagePreview: String?
    let lastMessageAt: Date?
}

/// One message inside a support conversation.
struct SupportMessage: Identifiable, Hashable {
    let id: UUID
    let conversationId: UUID
    let senderId: UUID
    let body: String
    let createdAt: Date
}
