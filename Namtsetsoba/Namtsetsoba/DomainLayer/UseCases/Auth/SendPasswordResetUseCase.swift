import Foundation

/// Sends a password-reset email.
protocol SendPasswordResetUseCase {
    func execute(email: String) async throws
}

struct SendPasswordResetUseCaseImpl: SendPasswordResetUseCase {
    private let gateway: AuthGateway

    init(gateway: AuthGateway) {
        self.gateway = gateway
    }

    func execute(email: String) async throws {
        try await gateway.sendPasswordReset(email: email)
    }
}
