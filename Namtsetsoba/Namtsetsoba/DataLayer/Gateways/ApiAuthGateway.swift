import Foundation
import Supabase

/// Supabase-backed implementation of `AuthGateway`.
final class ApiAuthGateway: AuthGateway {
    private let client: SupabaseClient
    private let redirectURL = URL(string: "https://electrolizzys.github.io/Namcecoba-App/")

    init(client: SupabaseClient = SupabaseClientProvider.client) {
        self.client = client
    }

    func currentUser() async throws -> AuthenticatedUser {
        let user = try await client.auth.session.user
        return AuthenticatedUser(id: user.id, email: user.email ?? "")
    }

    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String, username: String) async throws {
        try await client.auth.signUp(
            email: email,
            password: password,
            data: ["username": .string(username)]
        )
    }

    func sendPasswordReset(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email, redirectTo: redirectURL)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func updateUsername(_ username: String) async throws {
        try await client.auth.update(user: .init(data: ["username": .string(username)]))
    }

    func updatePassword(_ password: String) async throws {
        try await client.auth.update(user: .init(password: password))
    }
}
