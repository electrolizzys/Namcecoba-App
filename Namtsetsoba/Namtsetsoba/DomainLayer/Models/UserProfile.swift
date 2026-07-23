import Foundation

/// The signed-in user's profile as understood by the domain.
struct UserProfile {
    let id: UUID
    let username: String
    let email: String
    let role: UserRole
    /// Set only for venue accounts.
    let storeId: UUID?
}
