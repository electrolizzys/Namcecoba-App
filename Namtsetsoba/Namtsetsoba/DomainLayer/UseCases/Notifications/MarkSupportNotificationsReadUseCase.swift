import Foundation

/// Marks unread support notifications as read for a conversation (or all support alerts).
protocol MarkSupportNotificationsReadUseCase {
    func execute(userId: UUID, conversationId: UUID?) async throws
}

struct MarkSupportNotificationsReadUseCaseImpl: MarkSupportNotificationsReadUseCase {
    private let gateway: NotificationGateway

    init(gateway: NotificationGateway) {
        self.gateway = gateway
    }

    func execute(userId: UUID, conversationId: UUID?) async throws {
        try await gateway.markSupportNotificationsRead(userId: userId, conversationId: conversationId)
    }
}
