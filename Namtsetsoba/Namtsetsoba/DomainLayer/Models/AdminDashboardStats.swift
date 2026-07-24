import Foundation

/// High-level KPI snapshot for the admin home screen.
struct AdminDashboardStats: Hashable {
    let period: SalesPeriod
    let pickedUpRevenue: Decimal
    let platformCommission: Decimal
    let storeIncome: Decimal
    let pickedUpOrderCount: Int
    let cancelledOrderCount: Int
    let cancelRate: Double
    let activeStoreCount: Int
    let activeOfferCount: Int
    /// Distinct customers with at least one picked-up order in the period.
    let customersWithPickupCount: Int
}
