import Foundation

/// Two-way support chat between admins and customers/venues.
protocol SupportChatGateway {
    /// Opens (or returns) the signed-in user's conversation. Nil until first message if none exists.
    func fetchMyConversation() async throws -> SupportConversation?
    /// Admin inbox — all threads, newest activity first.
    func fetchAllConversations() async throws -> [SupportConversation]
    func fetchConversation(id: UUID) async throws -> SupportConversation?
    /// Admin: get or create a thread for a customer/venue user (so admin can text first).
    func openConversation(forUserId: UUID) async throws -> SupportConversation
    func fetchMessages(conversationId: UUID) async throws -> [SupportMessage]
    /// Sends a message. Non-admins omit `conversationId` (their thread is opened automatically).
    /// Admins must pass the target conversation id.
    @discardableResult
    func sendMessage(body: String, conversationId: UUID?) async throws -> UUID
}
