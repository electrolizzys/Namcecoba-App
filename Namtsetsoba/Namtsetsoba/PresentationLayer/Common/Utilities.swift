import Foundation

enum Utilities {
    private static let gelFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

    static func formatMoneyGel(_ amount: Decimal) -> String {
        let formatted = gelFormatter.string(from: amount as NSDecimalNumber) ?? "0.00"
        return "\(formatted) ₾"
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    static func formatPickupWindow(start: Date, end: Date) -> String {
        let s = timeFormatter.string(from: start)
        let e = timeFormatter.string(from: end)
        let isToday = Calendar.current.isDateInToday(start)
        return "\(isToday ? "Today" : "Tomorrow") \(s) – \(e)"
    }

    private static let orderDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    static func formatOrderDate(_ date: Date) -> String {
        orderDateFormatter.string(from: date)
    }
}
