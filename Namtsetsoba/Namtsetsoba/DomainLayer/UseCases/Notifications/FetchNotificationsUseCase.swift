import Foundation

/// Fetches a user's notifications, newest first.
protocol FetchNotificationsUseCase {
    func execute(userId: UUID, limit: Int) async throws -> [AppNotification]
}

struct FetchNotificationsUseCaseImpl: FetchNotificationsUseCase {
    private let gateway: NotificationGateway

    init(gateway: NotificationGateway) {
        self.gateway = gateway
    }

    func execute(userId: UUID, limit: Int) async throws -> [AppNotification] {
        try await gateway.fetchNotifications(userId: userId, limit: limit)
    }
}
