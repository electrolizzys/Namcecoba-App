import Foundation
import Observation

@Observable
final class CustomerAnalyticsViewModel {
    var period: AnalyticsPeriod = .month {
        didSet { recompute() }
    }
    var analytics: CustomerAnalytics = .empty
    var isLoading = false

    @ObservationIgnored private let fetchOrdersUseCase: FetchOrdersUseCase
    @ObservationIgnored private let computeUseCase: ComputeCustomerAnalyticsUseCase
    @ObservationIgnored private var orders: [Order] = []

    init(container: AppContainer = .shared) {
        fetchOrdersUseCase = container.fetchOrders
        computeUseCase = container.computeCustomerAnalytics
    }

    @MainActor
    func load(userId: UUID) async {
        isLoading = true
        orders = (try? await fetchOrdersUseCase.execute(userId: userId)) ?? []
        recompute()
        isLoading = false
    }

    private func recompute() {
        analytics = computeUseCase.execute(orders: orders, period: period)
    }
}
