import Foundation

/// Aggregated activity and impact metrics for a customer over a reporting window.
struct CustomerAnalytics {
    let period: AnalyticsPeriod
    /// Orders placed in the period, regardless of status.
    let ordersPlaced: Int
    /// Surprise bags actually collected.
    let bagsRescued: Int
    /// Total money saved versus original prices on collected bags.
    let moneySaved: Decimal
    /// Total money spent on collected bags.
    let totalSpent: Decimal
    let averageSavingsPercent: Int
    let co2SavedKg: Double
    /// Store the customer ordered from most often in the period.
    let favouriteStoreName: String?

    static let empty = CustomerAnalytics(
        period: .allTime,
        ordersPlaced: 0,
        bagsRescued: 0,
        moneySaved: 0,
        totalSpent: 0,
        averageSavingsPercent: 0,
        co2SavedKg: 0,
        favouriteStoreName: nil
    )
}
