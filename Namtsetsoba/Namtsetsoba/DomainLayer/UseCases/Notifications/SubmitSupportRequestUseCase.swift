import Foundation

/// Submits an in-app support message that becomes an admin notification.
protocol SubmitSupportRequestUseCase {
    func execute(message: String) async throws
}

struct SubmitSupportRequestUseCaseImpl: SubmitSupportRequestUseCase {
    private let gateway: NotificationGateway

    init(gateway: NotificationGateway) {
        self.gateway = gateway
    }

    func execute(message: String) async throws {
        try await gateway.submitSupportRequest(message: message)
    }
}
