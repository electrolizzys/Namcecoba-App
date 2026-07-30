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
    /// Localized header for the Alerts list. Bodies stay as stored (basket/store names, user text).
    var localizedTitle: String {
        switch type {
        case .favourite:
            return L(.alertTitleNewOffer)
        case .support:
            if let name = Self.supportSenderName(from: title) {
                return String(format: L(.alertTitleSupportFrom), name)
            }
            return L(.alertTitleSupport)
        case .order:
            switch Self.orderKind(from: title) {
            case .cancelled: return L(.alertTitleOrderCancelled)
            case .ready: return L(.alertTitleOrderReady)
            case .pickedUp: return L(.alertTitleOrderPickedUp)
            case .newOrder: return L(.alertTitleNewOrder)
            case .unknown: return title
            }
        }
    }

    /// Icon differs by order lifecycle (titles come from DB triggers).
    var systemImage: String {
        switch type {
        case .favourite:
            return "bag.heart.fill"
        case .support:
            return "lifepreserver.fill"
        case .order:
            switch Self.orderKind(from: title) {
            case .cancelled: return "xmark.circle.fill"
            case .ready: return "takeoutbag.and.cup.and.straw.fill"
            case .pickedUp: return "checkmark.circle.fill"
            case .newOrder: return "bell.badge.fill"
            case .unknown: return "bag.fill"
            }
        }
    }

    var iconColor: Color {
        switch type {
        case .favourite:
            return Color(red: 0.92, green: 0.28, blue: 0.48)
        case .support:
            return AdminPalette.purple
        case .order:
            switch Self.orderKind(from: title) {
            case .cancelled: return .red
            case .ready: return DesignTokens.primaryGreen
            case .pickedUp: return .secondary
            case .newOrder: return .orange
            case .unknown: return .blue
            }
        }
    }

    /// Order row whose title indicates cancellation (solid red icon in notification list).
    var isCancelledOrderNotification: Bool {
        type == .order && Self.orderKind(from: title) == .cancelled
    }

    private enum OrderNotificationKind {
        case newOrder, ready, pickedUp, cancelled, unknown
    }

    private static func orderKind(from title: String) -> OrderNotificationKind {
        let t = title.lowercased()
        if t.contains("cancelled") || t.contains("გაუქმ") { return .cancelled }
        if t.contains("ready") || t.contains("მზად") { return .ready }
        if t.contains("picked") || t.contains("აღებ") { return .pickedUp }
        if t.contains("new order") || t.contains("ახალი შეკვეთ") { return .newOrder }
        return .unknown
    }

    private static func supportSenderName(from title: String) -> String? {
        let prefixes = ["Support from ", "მხარდაჭერა: ", "მხარდაჭერა "]
        for prefix in prefixes {
            if title.hasPrefix(prefix) {
                let name = String(title.dropFirst(prefix.count))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return name.isEmpty ? nil : name
            }
        }
        return nil
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
