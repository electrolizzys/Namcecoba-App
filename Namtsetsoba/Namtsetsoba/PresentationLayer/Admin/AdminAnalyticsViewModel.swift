import Foundation
import Observation

@Observable
final class AdminAnalyticsViewModel {
    var period: SalesPeriod = .lastMonth
    var snapshot: AdminAnalyticsSnapshot?
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored private let fetchAnalytics: FetchAdminAnalyticsUseCase

    init(container: AppContainer = .shared) {
        fetchAnalytics = container.fetchAdminAnalytics
    }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            snapshot = try await fetchAnalytics.execute(period: period)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
