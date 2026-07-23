import Foundation

/// Removes an APNs token for a user (called on sign-out).
protocol RemoveDeviceTokenUseCase {
    func execute(userId: UUID, token: String) async throws
}

struct RemoveDeviceTokenUseCaseImpl: RemoveDeviceTokenUseCase {
    private let gateway: DeviceTokenGateway

    init(gateway: DeviceTokenGateway) {
        self.gateway = gateway
    }

    func execute(userId: UUID, token: String) async throws {
        try await gateway.remove(userId: userId, token: token)
    }
}
