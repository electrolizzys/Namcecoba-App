import Foundation

/// An in-app notification shown in the Notifications tab.
///
/// Icon/colour/relative-time formatting live in `AppNotification+Presentation`.
struct AppNotification: Identifiable {
    let id: UUID
    let title: String
    let body: String
    let type: NotificationType
    let referenceId: UUID?
    var isRead: Bool
    let createdAt: Date
}
