import SwiftUI

extension NotificationType {
    /// Short label used by the notification-type filter chips.
    var filterTitle: String {
        switch self {
        case .order: return "Orders"
        case .favourite: return "Offers"
        }
    }

    /// SF Symbol used by the notification-type filter chips.
    var filterIcon: String {
        switch self {
        case .order: return "bag.fill"
        case .favourite: return "heart.fill"
        }
    }
}

extension AppNotification {
    /// Icon differs by order lifecycle (titles come from DB triggers).
    var systemImage: String {
        switch type {
        case .favourite:
            return "bag.heart.fill"
        case .order:
            let t = title.lowercased()
            if t.contains("cancelled") { return "xmark.circle.fill" }
            if t.contains("ready") { return "takeoutbag.and.cup.and.straw.fill" }
            if t.contains("picked") { return "checkmark.circle.fill" }
            if t.contains("new order") { return "bell.badge.fill" }
            return "bag.fill"
        }
    }

    var iconColor: Color {
        switch type {
        case .favourite:
            return Color(red: 0.92, green: 0.28, blue: 0.48)
        case .order:
            let t = title.lowercased()
            if t.contains("cancelled") { return .red }
            if t.contains("ready") { return DesignTokens.primaryGreen }
            if t.contains("picked") { return .secondary }
            if t.contains("new order") { return .orange }
            return .blue
        }
    }

    /// Order row whose title indicates cancellation (solid red icon in notification list).
    var isCancelledOrderNotification: Bool {
        type == .order && title.localizedCaseInsensitiveContains("cancelled")
    }

    /// Human-friendly relative time ("Just now", "5m ago", …).
    var timeAgo: String {
        let interval = Date().timeIntervalSince(createdAt)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        return "\(Int(interval / 86400))d ago"
    }
}
