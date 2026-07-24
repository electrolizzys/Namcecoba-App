import Foundation

/// Reporting window for admin sales / dashboard / analytics.
enum SalesPeriod: String, CaseIterable, Identifiable {
    case lastMonth
    case lastQuarter
    case lastYear

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lastMonth: "Last month"
        case .lastQuarter: "Last quarter"
        case .lastYear: "Last year"
        }
    }

    /// Inclusive start of the selected window (relative to `now`).
    func startDate(relativeTo now: Date = Date()) -> Date {
        let calendar = Calendar.current
        switch self {
        case .lastMonth:
            return calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .lastQuarter:
            return calendar.date(byAdding: .month, value: -3, to: now) ?? now
        case .lastYear:
            return calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
    }
}
