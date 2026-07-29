import Foundation

/// Notification reads, read-state updates, and support submissions.
protocol NotificationGateway {
    func fetchNotifications(userId: UUID, limit: Int) async throws -> [AppNotification]
    func markAsRead(id: UUID) async throws
    func markAllAsRead(userId: UUID) async throws
    /// Marks unread support alerts for this conversation (or all support alerts if `conversationId` is nil).
    func markSupportNotificationsRead(userId: UUID, conversationId: UUID?) async throws
    /// Sends a support message to every admin account (via edge function).
    func submitSupportRequest(message: String) async throws
}
