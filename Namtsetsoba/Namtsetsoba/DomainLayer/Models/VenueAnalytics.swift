import Foundation

/// Aggregated performance metrics for a single venue over a reporting window.
struct VenueAnalytics {
    let period: AnalyticsPeriod
    /// Money customers paid for picked-up orders in the period.
    let grossRevenue: Decimal
    /// Revenue kept by the store after the platform commission.
    let storeIncome: Decimal
    /// Platform commission taken from `grossRevenue`.
    let platformFee: Decimal
    let pickedUpCount: Int
    let cancelledCount: Int
    /// Orders awaiting handover right now (confirmed + ready), independent of the period.
    let activeOrderCount: Int
    let averageOrderValue: Decimal
    /// Share of finished orders that were actually collected (0...1).
    let pickupRate: Double
    /// Number of surprise bags rescued from waste (== picked-up count).
    let mealsSaved: Int
    /// Distinct customers who collected an order in the period.
    let uniqueCustomers: Int
    /// Share of those customers who collected more than once (0...1).
    let repeatCustomerRate: Double
    /// Total value handed back to customers as discounts.
    let customerSavings: Decimal
    /// Average discount depth across picked-up bags, as a whole percent.
    let averageSavingsPercent: Int
    let co2SavedKg: Double

    static let empty = VenueAnalytics(
        period: .allTime,
        grossRevenue: 0,
        storeIncome: 0,
        platformFee: 0,
        pickedUpCount: 0,
        cancelledCount: 0,
        activeOrderCount: 0,
        averageOrderValue: 0,
        pickupRate: 0,
        mealsSaved: 0,
        uniqueCustomers: 0,
        repeatCustomerRate: 0,
        customerSavings: 0,
        averageSavingsPercent: 0,
        co2SavedKg: 0
    )
}
