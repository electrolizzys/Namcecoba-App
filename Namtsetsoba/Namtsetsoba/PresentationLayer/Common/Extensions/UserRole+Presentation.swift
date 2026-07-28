import Foundation

extension UserRole {
    var displayName: String {
        switch self {
        case .customer: "Customer"
        case .business: "Venue"
        case .admin: "Admin"
        }
    }

    /// Localized, user-facing role name.
    var localizedName: String {
        switch self {
        case .customer: L(.roleCustomer)
        case .business: L(.roleVenue)
        case .admin: L(.roleAdmin)
        }
    }
}
