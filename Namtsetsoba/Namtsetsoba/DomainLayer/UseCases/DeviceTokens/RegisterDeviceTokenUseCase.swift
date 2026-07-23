import Foundation

/// Stores/updates the APNs token for a user.
protocol RegisterDeviceTokenUseCase {
    func execute(userId: UUID, token: String) async throws
}

struct RegisterDeviceTokenUseCaseImpl: RegisterDeviceTokenUseCase {
    private let gateway: DeviceTokenGateway

    init(gateway: DeviceTokenGateway) {
        self.gateway = gateway
    }

    func execute(userId: UUID, token: String) async throws {
        try await gateway.upsert(userId: userId, token: token)
    }
}
