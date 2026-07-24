import Foundation

/// Lifecycle state of a customer order.
///
/// Colours and SF Symbols for each state live in `OrderStatus+Presentation`.
enum OrderStatus: String, Codable, CaseIterable {
    case confirmed
    case readyForPickup
    case pickedUp
    case cancelled

    var displayName: String {
        switch self {
        case .confirmed: "Confirmed"
        case .readyForPickup: "Ready for Pickup"
        case .pickedUp: "Picked Up"
        case .cancelled: "Cancelled"
        }
    }
}
