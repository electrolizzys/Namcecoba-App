import Foundation

/// Authentication and account operations the domain depends on.
///
/// Implemented in the data layer (`ApiAuthGateway`). No transport details leak here.
protocol AuthGateway {
    /// Returns the active session's user, or throws if there is no valid session.
    func currentUser() async throws -> AuthenticatedUser

    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String, username: String) async throws
    func sendPasswordReset(email: String) async throws
    func signOut() async throws

    func updateUsername(_ username: String) async throws
    func updatePassword(_ password: String) async throws
}
