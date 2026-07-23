import Foundation

/// Loads the profile for the currently authenticated user.
protocol LoadUserProfileUseCase {
    func execute() async throws -> UserProfile
}

struct LoadUserProfileUseCaseImpl: LoadUserProfileUseCase {
    private let authGateway: AuthGateway
    private let profileGateway: ProfileGateway

    init(authGateway: AuthGateway, profileGateway: ProfileGateway) {
        self.authGateway = authGateway
        self.profileGateway = profileGateway
    }

    func execute() async throws -> UserProfile {
        let user = try await authGateway.currentUser()
        var profile = try await profileGateway.fetchProfile(userId: user.id)
        // Prefer the auth email when the profile row has none stored.
        if profile.email.isEmpty {
            profile = UserProfile(
                id: profile.id,
                username: profile.username,
                email: user.email,
                role: profile.role,
                storeId: profile.storeId
            )
        }
        return profile
    }
}
