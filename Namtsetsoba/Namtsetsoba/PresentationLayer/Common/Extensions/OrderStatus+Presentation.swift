import SwiftUI

extension OrderStatus {
    /// Accent colour used for status labels and icons.
    var color: Color {
        switch self {
        case .confirmed: .blue
        case .readyForPickup: .green
        case .pickedUp: .secondary
        case .cancelled: .red
        }
    }

    /// SF Symbol representing the status.
    var systemImage: String {
        switch self {
        case .confirmed: "checkmark.circle.fill"
        case .readyForPickup: "bag.fill"
        case .pickedUp: "checkmark.seal.fill"
        case .cancelled: "xmark.circle.fill"
        }
    }
}
