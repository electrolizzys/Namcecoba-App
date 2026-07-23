import Foundation

/// Returns the currently authenticated user, or throws when signed out.
protocol GetCurrentUserUseCase {
    func execute() async throws -> AuthenticatedUser
}

struct GetCurrentUserUseCaseImpl: GetCurrentUserUseCase {
    private let gateway: AuthGateway

    init(gateway: AuthGateway) {
        self.gateway = gateway
    }

    func execute() async throws -> AuthenticatedUser {
        try await gateway.currentUser()
    }
}
