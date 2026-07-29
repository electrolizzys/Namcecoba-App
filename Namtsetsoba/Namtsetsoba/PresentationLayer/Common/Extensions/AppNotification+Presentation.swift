import SwiftUI

extension NotificationType {
    /// Short label used by the notification-type filter chips.
    var filterTitle: String {
        switch self {
        case .order: L(.alertsFilterOrders)
        case .favourite: L(.alertsFilterOffers)
        case .support: L(.alertsFilterSupport)
        }
    }

    /// SF Symbol used by the notification-type filter chips.
    var filterIcon: String {
        switch self {
        case .order: "bag.fill"
        case .favourite: "heart.fill"
        case .support: "lifepreserver.fill"
        }
    }
}

extension AppNotification {
    /// Icon differs by order lifecycle (titles come from DB triggers).
    var systemImage: String {
        switch type {
        case .favourite:
            return "bag.heart.fill"
        case .support:
            return "lifepreserver.fill"
        case .order:
            let t = title.lowercased()
            if t.contains("cancelled") || t.contains("გაუქმ") { return "xmark.circle.fill" }
            if t.contains("ready") || t.contains("მზად") { return "takeoutbag.and.cup.and.straw.fill" }
            if t.contains("picked") || t.contains("აღებ") { return "checkmark.circle.fill" }
            if t.contains("new order") || t.contains("ახალი") { return "bell.badge.fill" }
            return "bag.fill"
        }
    }

    var iconColor: Color {
        switch type {
        case .favourite:
            return Color(red: 0.92, green: 0.28, blue: 0.48)
        case .support:
            return AdminPalette.purple
        case .order:
            let t = title.lowercased()
            if t.contains("cancelled") || t.contains("გაუქმ") { return .red }
            if t.contains("ready") || t.contains("მზად") { return DesignTokens.primaryGreen }
            if t.contains("picked") || t.contains("აღებ") { return .secondary }
            if t.contains("new order") || t.contains("ახალი") { return .orange }
            return .blue
        }
    }

    /// Order row whose title indicates cancellation (solid red icon in notification list).
    var isCancelledOrderNotification: Bool {
        type == .order && (
            title.localizedCaseInsensitiveContains("cancelled")
            || title.localizedCaseInsensitiveContains("გაუქმ")
        )
    }

    /// Human-friendly relative time ("Just now", "5m ago", …).
    var timeAgo: String {
        let interval = Date().timeIntervalSince(createdAt)
        if interval < 60 { return L(.alertsJustNow) }
        if interval < 3600 { return String(format: L(.alertsMinutesAgo), Int(interval / 60)) }
        if interval < 86400 { return String(format: L(.alertsHoursAgo), Int(interval / 3600)) }
        return String(format: L(.alertsDaysAgo), Int(interval / 86400))
    }
}
