import Foundation

/// Marks every unread notification for a user as read.
protocol MarkAllNotificationsAsReadUseCase {
    func execute(userId: UUID) async throws
}

struct MarkAllNotificationsAsReadUseCaseImpl: MarkAllNotificationsAsReadUseCase {
    private let gateway: NotificationGateway

    init(gateway: NotificationGateway) {
        self.gateway = gateway
    }

    func execute(userId: UUID) async throws {
        try await gateway.markAllAsRead(userId: userId)
    }
}
