import Foundation

/// Updates the signed-in user's display name.
protocol UpdateUsernameUseCase {
    func execute(username: String) async throws
}

struct UpdateUsernameUseCaseImpl: UpdateUsernameUseCase {
    private let gateway: AuthGateway

    init(gateway: AuthGateway) {
        self.gateway = gateway
    }

    func execute(username: String) async throws {
        try await gateway.updateUsername(username)
    }
}
