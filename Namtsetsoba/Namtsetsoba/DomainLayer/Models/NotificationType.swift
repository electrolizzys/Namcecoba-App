import Foundation

/// Category of an in-app notification.
enum NotificationType: String, CaseIterable, Identifiable {
    /// Order lifecycle updates (new order, ready, picked up, cancelled).
    case order
    /// A favourited store published a new basket.
    case favourite

    var id: String { rawValue }
}
