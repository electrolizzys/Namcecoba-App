import Foundation

extension UserRole {
    var localizedName: String {
        switch self {
        case .customer: L(.roleCustomer)
        case .business: L(.roleVenue)
        case .admin: L(.roleAdmin)
        }
    }
}
