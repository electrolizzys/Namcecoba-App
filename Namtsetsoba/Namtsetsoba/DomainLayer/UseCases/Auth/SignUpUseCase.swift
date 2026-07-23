import Foundation

/// Registers a new customer account.
protocol SignUpUseCase {
    func execute(email: String, password: String, username: String) async throws
}

struct SignUpUseCaseImpl: SignUpUseCase {
    private let gateway: AuthGateway

    init(gateway: AuthGateway) {
        self.gateway = gateway
    }

    func execute(email: String, password: String, username: String) async throws {
        try await gateway.signUp(email: email, password: password, username: username)
    }
}
