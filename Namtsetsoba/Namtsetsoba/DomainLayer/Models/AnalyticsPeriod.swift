import Foundation

/// Reporting window used by the customer and venue analytics screens.
enum AnalyticsPeriod: String, CaseIterable, Identifiable {
    case today
    case week
    case month
    case allTime

    var id: String { rawValue }

    /// Inclusive lower bound for the window, or `nil` when the period covers everything.
    func startDate(relativeTo now: Date = Date()) -> Date? {
        let calendar = Calendar.current
        switch self {
        case .today:
            return calendar.startOfDay(for: now)
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: now)
        case .month:
            return calendar.date(byAdding: .month, value: -1, to: now)
        case .allTime:
            return nil
        }
    }

    /// Whether `date` falls inside this window.
    func contains(_ date: Date, relativeTo now: Date = Date()) -> Bool {
        guard let start = startDate(relativeTo: now) else { return true }
        return date >= start
    }
}
