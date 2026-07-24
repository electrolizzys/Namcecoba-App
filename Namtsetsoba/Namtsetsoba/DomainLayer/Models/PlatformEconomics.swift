import Foundation

/// Platform-wide money rules used by admin sales and dashboard reporting.
enum PlatformEconomics {
    /// Fixed share of each successfully picked-up order kept by the platform.
    static let commissionRate: Decimal = Decimal(string: "0.10")!

    static func commission(from totalPaid: Decimal) -> Decimal {
        totalPaid * commissionRate
    }

    static func storeIncome(from totalPaid: Decimal) -> Decimal {
        totalPaid - commission(from: totalPaid)
    }
}
