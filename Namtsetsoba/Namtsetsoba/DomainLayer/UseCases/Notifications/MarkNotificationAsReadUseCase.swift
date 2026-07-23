import Foundation

/// Marks a single notification as read.
protocol MarkNotificationAsReadUseCase {
    func execute(id: UUID) async throws
}

struct MarkNotificationAsReadUseCaseImpl: MarkNotificationAsReadUseCase {
    private let gateway: NotificationGateway

    init(gateway: NotificationGateway) {
        self.gateway = gateway
    }

    func execute(id: UUID) async throws {
        try await gateway.markAsRead(id: id)
    }
}
