import Foundation

/// Aggregates a customer's orders into `CustomerAnalytics` for a reporting window.
protocol ComputeCustomerAnalyticsUseCase {
    func execute(orders: [Order], period: AnalyticsPeriod) -> CustomerAnalytics
}

struct ComputeCustomerAnalyticsUseCaseImpl: ComputeCustomerAnalyticsUseCase {
    func execute(orders: [Order], period: AnalyticsPeriod) -> CustomerAnalytics {
        let inPeriod = orders.filter { period.contains($0.orderDate) }
        let pickedUp = inPeriod.filter { $0.status == .pickedUp }

        let moneySaved = pickedUp.reduce(Decimal.zero) {
            $0 + ($1.basket.originalPrice - $1.totalPaid)
        }
        let totalSpent = pickedUp.reduce(Decimal.zero) { $0 + $1.totalPaid }

        let averageSavingsPercent: Int
        if pickedUp.isEmpty {
            averageSavingsPercent = 0
        } else {
            let sum = pickedUp.reduce(0) { $0 + $1.basket.savingsPercent }
            averageSavingsPercent = sum / pickedUp.count
        }

        let favouriteStoreName = Dictionary(grouping: inPeriod, by: { $0.basket.store.name })
            .max { $0.value.count < $1.value.count }?
            .key

        return CustomerAnalytics(
            period: period,
            ordersPlaced: inPeriod.count,
            bagsRescued: pickedUp.count,
            moneySaved: moneySaved,
            totalSpent: totalSpent,
            averageSavingsPercent: averageSavingsPercent,
            co2SavedKg: Double(pickedUp.count) * SustainabilityImpact.co2PerBagKg,
            favouriteStoreName: favouriteStoreName
        )
    }
}
