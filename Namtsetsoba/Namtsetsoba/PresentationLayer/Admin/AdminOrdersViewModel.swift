import Foundation
import Observation

@Observable
final class AdminOrdersViewModel {
    var orders: [Order] = []
    var statusFilter: OrderStatus?
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored private let fetchOrders: FetchAdminOrdersUseCase

    init(container: AppContainer = .shared) {
        fetchOrders = container.fetchAdminOrders
    }

    var filteredOrders: [Order] {
        guard let statusFilter else { return orders }
        return orders.filter { $0.status == statusFilter }
    }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            orders = try await fetchOrders.execute(limit: 150)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
