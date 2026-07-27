import Foundation

/// Aggregates a venue's orders into `VenueAnalytics` for a reporting window.
protocol ComputeVenueAnalyticsUseCase {
    func execute(orders: [Order], period: AnalyticsPeriod) -> VenueAnalytics
}

struct ComputeVenueAnalyticsUseCaseImpl: ComputeVenueAnalyticsUseCase {
    func execute(orders: [Order], period: AnalyticsPeriod) -> VenueAnalytics {
        let inPeriod = orders.filter { period.contains($0.orderDate) }
        let pickedUp = inPeriod.filter { $0.status == .pickedUp }
        let cancelled = inPeriod.filter { $0.status == .cancelled }

        // Active orders reflect the current queue, so they are not period-bound.
        let active = orders.filter { $0.status == .confirmed || $0.status == .readyForPickup }

        let gross = pickedUp.reduce(Decimal.zero) { $0 + $1.totalPaid }
        let fee = PlatformEconomics.commission(from: gross)
        let income = gross - fee

        let finished = pickedUp.count + cancelled.count
        let pickupRate = finished == 0 ? 0 : Double(pickedUp.count) / Double(finished)

        let averageOrderValue = pickedUp.isEmpty ? Decimal.zero : gross / Decimal(pickedUp.count)

        let customerSavings = pickedUp.reduce(Decimal.zero) {
            $0 + ($1.basket.originalPrice - $1.totalPaid)
        }

        let averageSavingsPercent: Int
        if pickedUp.isEmpty {
            averageSavingsPercent = 0
        } else {
            averageSavingsPercent = pickedUp.reduce(0) { $0 + $1.basket.savingsPercent } / pickedUp.count
        }

        let customersById = Dictionary(grouping: pickedUp.compactMap(\.userId), by: { $0 })
        let uniqueCustomers = customersById.count
        let repeatCustomers = customersById.values.filter { $0.count >= 2 }.count
        let repeatCustomerRate = uniqueCustomers == 0 ? 0 : Double(repeatCustomers) / Double(uniqueCustomers)

        return VenueAnalytics(
            period: period,
            grossRevenue: gross,
            storeIncome: income,
            platformFee: fee,
            pickedUpCount: pickedUp.count,
            cancelledCount: cancelled.count,
            activeOrderCount: active.count,
            averageOrderValue: averageOrderValue,
            pickupRate: pickupRate,
            mealsSaved: pickedUp.count,
            uniqueCustomers: uniqueCustomers,
            repeatCustomerRate: repeatCustomerRate,
            customerSavings: customerSavings,
            averageSavingsPercent: averageSavingsPercent,
            co2SavedKg: Double(pickedUp.count) * SustainabilityImpact.co2PerBagKg
        )
    }
}
