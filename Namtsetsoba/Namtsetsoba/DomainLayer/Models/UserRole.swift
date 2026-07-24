import Foundation

/// The kind of account currently signed in.
enum UserRole: String, Codable {
    case customer
    case business
    case admin
}
