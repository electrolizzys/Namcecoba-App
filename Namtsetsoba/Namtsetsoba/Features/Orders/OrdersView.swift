import SwiftUI

struct OrdersView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            Group {
                if appState.currentRole == .business {
                    storeOrdersContent
                } else {
                    customerOrdersContent
                }
            }
            .navigationTitle(appState.currentRole == .business ? "Incoming Orders" : "Orders")
            .refreshable { await appState.loadOrders() }
        }
    }

    // MARK: - Customer View

    private var customerOrdersContent: some View {
        Group {
            if appState.orders.isEmpty {
                emptyState(message: "Your orders will appear here after you place one")
            } else {
                customerOrderList
            }
        }
    }

    private var customerOrderList: some View {
        let active = appState.orders.filter {
            $0.status == .confirmed || $0.status == .readyForPickup
        }
        let past = appState.orders.filter {
            $0.status == .pickedUp || $0.status == .cancelled
        }

        return List {
            if !active.isEmpty {
                Section("Active") {
                    ForEach(active) { order in
                        NavigationLink(value: order) {
                            OrderRow(order: order, isStoreView: false)
                        }
                    }
                }
            }

            if !past.isEmpty {
                Section("History") {
                    ForEach(past) { order in
                        NavigationLink(value: order) {
                            OrderRow(order: order, isStoreView: false)
                        }
                    }
                }
            }
        }
        .navigationDestination(for: Order.self) { order in
            OrderDetailView(order: order)
        }
    }

    // MARK: - Store View

    private var storeOrdersContent: some View {
        Group {
            if appState.storeOrders.isEmpty {
                emptyState(message: "Orders from customers will appear here")
            } else {
                storeOrderList
            }
        }
    }

    private var storeOrderList: some View {
        let current = appState.storeOrders.filter {
            $0.status == .confirmed || $0.status == .readyForPickup
        }
        let past = appState.storeOrders.filter {
            $0.status == .pickedUp || $0.status == .cancelled
        }

        return List {
            if !current.isEmpty {
                Section("Current Orders") {
                    ForEach(current) { order in
                        NavigationLink(value: order) {
                            OrderRow(order: order, isStoreView: true)
                        }
                    }
                }
            }

            if !past.isEmpty {
                DisclosureGroup("Past Orders (\(past.count))") {
                    ForEach(past) { order in
                        NavigationLink(value: order) {
                            OrderRow(order: order, isStoreView: true)
                        }
                    }
                }
            }
        }
        .navigationDestination(for: Order.self) { order in
            OrderDetailView(order: order)
        }
    }

    // MARK: - Empty State

    private func emptyState(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "bag")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No orders yet")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Order Row

struct OrderRow: View {
    let order: Order
    var isStoreView: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(order.basket.title)
                    .font(.headline)
                Spacer()
                Label(order.status.displayName, systemImage: order.status.systemImage)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(order.status.color)
            }

            if !isStoreView {
                Text(order.basket.store.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text(Utilities.formatOrderDate(order.orderDate))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(Utilities.formatMoneyGel(order.totalPaid))
                    .font(.subheadline.bold())
            }

            if order.status == .confirmed || order.status == .readyForPickup {
                HStack {
                    Text("Pickup Code:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(order.pickupCode)
                        .font(.caption.bold().monospaced())
                }
                .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    OrdersView()
        .environment(AppState())
}
