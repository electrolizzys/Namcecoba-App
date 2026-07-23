import Foundation

/// Signs a user in with email + password.
protocol SignInUseCase {
    func execute(email: String, password: String) async throws
}

struct SignInUseCaseImpl: SignInUseCase {
    private let gateway: AuthGateway

    init(gateway: AuthGateway) {
        self.gateway = gateway
    }

    func execute(email: String, password: String) async throws {
        try await gateway.signIn(email: email, password: password)
    }
}
