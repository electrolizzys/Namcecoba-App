import Foundation

extension UserRole {
    var displayName: String {
        switch self {
        case .customer: "Customer"
        case .business: "Venue"
        case .admin: "Admin"
        }
    }
}
