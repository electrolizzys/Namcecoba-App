import Foundation

/// Re-authenticates with the current password, then sets a new one.
protocol ChangePasswordUseCase {
    func execute(email: String, currentPassword: String, newPassword: String) async throws
}

struct ChangePasswordUseCaseImpl: ChangePasswordUseCase {
    private let gateway: AuthGateway

    init(gateway: AuthGateway) {
        self.gateway = gateway
    }

    func execute(email: String, currentPassword: String, newPassword: String) async throws {
        // Verify the current password by signing in before updating.
        try await gateway.signIn(email: email, password: currentPassword)
        try await gateway.updatePassword(newPassword)
    }
}
