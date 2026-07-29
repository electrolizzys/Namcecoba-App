import Foundation
import Observation

@Observable
final class VenueAnalyticsViewModel {
    var period: AnalyticsPeriod = .month {
        didSet { recompute() }
    }
    var analytics: VenueAnalytics = .empty
    var isLoading = false

    /// Average stars for ratings whose `createdAt` falls in `period`. Nil when none.
    var averageRatingInPeriod: Double?
    var ratingCountInPeriod: Int = 0

    @ObservationIgnored private let fetchStoreOrdersUseCase: FetchStoreOrdersUseCase
    @ObservationIgnored private let fetchStoreRatingsUseCase: FetchStoreRatingsUseCase
    @ObservationIgnored private let computeUseCase: ComputeVenueAnalyticsUseCase
    @ObservationIgnored private var orders: [Order] = []
    @ObservationIgnored private var ratings: [OrderRating] = []

    init(container: AppContainer = .shared) {
        fetchStoreOrdersUseCase = container.fetchStoreOrders
        fetchStoreRatingsUseCase = container.fetchStoreRatings
        computeUseCase = container.computeVenueAnalytics
    }

    @MainActor
    func load(storeId: UUID) async {
        isLoading = true
        async let fetchedOrders = fetchStoreOrdersUseCase.execute(storeId: storeId)
        async let fetchedRatings = fetchStoreRatingsUseCase.execute(storeId: storeId)
        orders = (try? await fetchedOrders) ?? []
        ratings = (try? await fetchedRatings) ?? []
        recompute()
        isLoading = false
    }

    private func recompute() {
        analytics = computeUseCase.execute(orders: orders, period: period)
        let inPeriod = ratings.filter { period.contains($0.createdAt) }
        ratingCountInPeriod = inPeriod.count
        if inPeriod.isEmpty {
            averageRatingInPeriod = nil
        } else {
            let sum = inPeriod.reduce(0) { $0 + $1.stars }
            averageRatingInPeriod = Double(sum) / Double(inPeriod.count)
        }
    }
}
