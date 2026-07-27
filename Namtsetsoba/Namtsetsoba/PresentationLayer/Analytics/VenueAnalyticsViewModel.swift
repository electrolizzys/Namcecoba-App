import Foundation
import Observation

@Observable
final class VenueAnalyticsViewModel {
    var period: AnalyticsPeriod = .month {
        didSet { recompute() }
    }
    var analytics: VenueAnalytics = .empty
    var isLoading = false

    @ObservationIgnored private let fetchStoreOrdersUseCase: FetchStoreOrdersUseCase
    @ObservationIgnored private let computeUseCase: ComputeVenueAnalyticsUseCase
    @ObservationIgnored private var orders: [Order] = []

    init(container: AppContainer = .shared) {
        fetchStoreOrdersUseCase = container.fetchStoreOrders
        computeUseCase = container.computeVenueAnalytics
    }

    @MainActor
    func load(storeId: UUID) async {
        isLoading = true
        orders = (try? await fetchStoreOrdersUseCase.execute(storeId: storeId)) ?? []
        recompute()
        isLoading = false
    }

    private func recompute() {
        analytics = computeUseCase.execute(orders: orders, period: period)
    }
}
