import Foundation

/// Aggregated picked-up sales for one store in a reporting period.
struct StoreSalesSummary: Identifiable, Hashable {
    var id: UUID { storeId }

    let storeId: UUID
    let storeName: String
    let orderCount: Int
    let totalRevenue: Decimal
    let platformCommission: Decimal
    let storeIncome: Decimal
}
