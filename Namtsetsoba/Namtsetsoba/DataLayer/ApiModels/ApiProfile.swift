import Foundation

/// API representation of a row in the `profiles` table.
struct ApiProfile: Decodable {
    let id: UUID
    let username: String?
    let email: String?
    let role: String
    let storeId: UUID?

    enum CodingKeys: String, CodingKey {
        case id, username, email, role
        case storeId = "store_id"
    }

    /// Maps the transport model to the domain `UserProfile`.
    /// The DB stores `venue` for business accounts.
    func toDomain() -> UserProfile {
        let mappedRole: UserRole
        switch role {
        case "venue":
            mappedRole = .business
        case "admin":
            mappedRole = .admin
        default:
            mappedRole = .customer
        }

        return UserProfile(
            id: id,
            username: username ?? "",
            email: email ?? "",
            role: mappedRole,
            storeId: storeId
        )
    }
}
