import Foundation

/// Compact analytics set for the admin statistics screen (intentionally small).
struct AdminAnalyticsSnapshot: Hashable {
    let period: SalesPeriod
    /// Order counts by status within the period (all statuses that appeared).
    let statusCounts: [OrderStatus: Int]
    /// Cancelled / (cancelled + picked up) in the period. 0 when both are zero.
    let cancelRate: Double
    /// Share of customers with 2+ picked-up orders in the period.
    let repeatCustomerRate: Double
    /// Average `totalPaid` across picked-up orders in the period.
    let averageOrderValue: Decimal
}
