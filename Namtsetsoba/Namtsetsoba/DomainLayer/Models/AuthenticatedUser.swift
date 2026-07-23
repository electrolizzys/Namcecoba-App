import Foundation

/// Minimal identity of the currently authenticated user.
struct AuthenticatedUser {
    let id: UUID
    let email: String
}
