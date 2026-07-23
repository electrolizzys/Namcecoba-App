import Foundation
import Observation

/// Order status transitions plus search/grouping for the Orders list and detail screens.
@Observable
final class OrdersViewModel {
    var searchText = ""

    @ObservationIgnored private let updateOrderStatusUseCase: UpdateOrderStatusUseCase

    init(container: AppContainer = .shared) {
        updateOrderStatusUseCase = container.updateOrderStatus
    }

    // MARK: - Search & Grouping

    /// Matches an order against the search field (store name, basket title or pickup code).
    private func matchesSearch(_ order: Order) -> Bool {
        guard !searchText.isEmpty else { return true }
        return order.basket.store.name.localizedCaseInsensitiveContains(searchText)
            || order.basket.title.localizedCaseInsensitiveContains(searchText)
            || order.pickupCode.localizedCaseInsensitiveContains(searchText)
    }

    func filtered(_ orders: [Order]) -> [Order] {
        orders.filter(matchesSearch)
    }

    func active(_ orders: [Order]) -> [Order] {
        filtered(orders).filter { $0.status == .confirmed || $0.status == .readyForPickup }
    }

    func past(_ orders: [Order]) -> [Order] {
        filtered(orders).filter { $0.status == .pickedUp || $0.status == .cancelled }
    }

    func confirmed(_ orders: [Order]) -> [Order] {
        active(orders).filter { $0.status == .confirmed }
    }

    // MARK: - Status Updates

    /// Updates a single order; returns `true` on success.
    func updateStatus(orderId: UUID, to status: OrderStatus) async -> Bool {
        do {
            try await updateOrderStatusUseCase.execute(orderId: orderId, status: status)
            return true
        } catch {
            print("⚠️ Failed to update order: \(error.localizedDescription)")
            return false
        }
    }

    /// Marks all given orders ready for pickup; returns the ids that succeeded.
    func markAllReady(_ orders: [Order]) async -> Set<UUID> {
        var succeeded: Set<UUID> = []
        for order in orders where await updateStatus(orderId: order.id, to: .readyForPickup) {
            succeeded.insert(order.id)
        }
        return succeeded
    }
}
