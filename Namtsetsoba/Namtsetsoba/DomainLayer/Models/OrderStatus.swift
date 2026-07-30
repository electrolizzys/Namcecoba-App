import Foundation

/// Lifecycle state of a customer order.
enum OrderStatus: String, Codable, CaseIterable {
    case confirmed
    case readyForPickup
    case pickedUp
    case cancelled
}
