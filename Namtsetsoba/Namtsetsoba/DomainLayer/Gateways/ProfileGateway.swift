import Foundation

/// Reads the signed-in user's profile record.
protocol ProfileGateway {
    func fetchProfile(userId: UUID) async throws -> UserProfile
}
