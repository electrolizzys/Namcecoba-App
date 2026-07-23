import Foundation

/// APNs device-token registration for push notifications.
protocol DeviceTokenGateway {
    func upsert(userId: UUID, token: String) async throws
    func remove(userId: UUID, token: String) async throws
}
