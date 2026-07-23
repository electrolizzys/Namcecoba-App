import Foundation

/// Notification reads and read-state updates.
protocol NotificationGateway {
    func fetchNotifications(userId: UUID, limit: Int) async throws -> [AppNotification]
    func markAsRead(id: UUID) async throws
    func markAllAsRead(userId: UUID) async throws
}
