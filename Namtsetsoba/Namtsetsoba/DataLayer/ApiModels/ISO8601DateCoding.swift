import Foundation

/// Shared ISO-8601 parsing/formatting for API payloads.
///
/// Postgres/Supabase timestamps sometimes include fractional seconds and sometimes
/// don't, so parsing falls back gracefully.
enum ISO8601DateCoding {
    private static let withFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let plain = ISO8601DateFormatter()

    /// Parses an ISO-8601 string, tolerating missing fractional seconds. Falls back to `now`.
    static func date(from string: String) -> Date {
        withFractional.date(from: string)
            ?? plain.date(from: string)
            ?? Date()
    }

    /// Formats a date as ISO-8601 (no fractional seconds) for writes.
    static func string(from date: Date) -> String {
        plain.string(from: date)
    }
}
