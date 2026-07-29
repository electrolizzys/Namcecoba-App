import Foundation

/// Category of an in-app notification.
enum NotificationType: String, CaseIterable, Identifiable {
    /// Order lifecycle updates (new order, ready, picked up, cancelled).
    case order
    /// A favourited store published a new basket.
    case favourite
    /// Customer/venue support message delivered to admins.
    case support

    var id: String { rawValue }
}
