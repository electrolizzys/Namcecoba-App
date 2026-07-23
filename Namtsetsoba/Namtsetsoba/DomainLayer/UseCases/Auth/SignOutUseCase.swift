import Foundation

/// Ends the current session.
protocol SignOutUseCase {
    func execute() async throws
}

struct SignOutUseCaseImpl: SignOutUseCase {
    private let gateway: AuthGateway

    init(gateway: AuthGateway) {
        self.gateway = gateway
    }

    func execute() async throws {
        try await gateway.signOut()
    }
}
