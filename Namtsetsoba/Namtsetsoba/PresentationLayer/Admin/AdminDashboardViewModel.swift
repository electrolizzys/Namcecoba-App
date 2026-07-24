import Foundation
import Observation

@Observable
final class AdminDashboardViewModel {
    var period: SalesPeriod = .lastMonth
    var stats: AdminDashboardStats?
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored private let fetchDashboard: FetchAdminDashboardUseCase

    init(container: AppContainer = .shared) {
        fetchDashboard = container.fetchAdminDashboard
    }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            stats = try await fetchDashboard.execute(period: period)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
