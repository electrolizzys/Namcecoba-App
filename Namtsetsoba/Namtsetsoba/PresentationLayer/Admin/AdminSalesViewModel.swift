import Foundation
import Observation

@Observable
final class AdminSalesViewModel {
    var period: SalesPeriod = .lastMonth
    var rows: [StoreSalesSummary] = []
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored private let fetchSales: FetchStoreSalesUseCase

    init(container: AppContainer = .shared) {
        fetchSales = container.fetchStoreSales
    }

    var totals: (revenue: Decimal, commission: Decimal, storeIncome: Decimal, orders: Int) {
        rows.reduce(into: (Decimal.zero, Decimal.zero, Decimal.zero, 0)) { acc, row in
            acc.0 += row.totalRevenue
            acc.1 += row.platformCommission
            acc.2 += row.storeIncome
            acc.3 += row.orderCount
        }
    }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            rows = try await fetchSales.execute(period: period)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
