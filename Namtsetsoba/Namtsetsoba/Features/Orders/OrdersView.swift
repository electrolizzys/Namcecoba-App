import SwiftUI

struct OrdersView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            Group {
                if appState.orders.isEmpty {
                    emptyState
                } else {
                    orderList
                }
            }
            .navigationTitle("Orders")
            .refreshable { await appState.loadOrders() }
        }
    }

    private var orderList: some View {
        List {
            let active = appState.orders.filter {
                $0.status == .confirmed || $0.status == .readyForPickup
            }
            let past = appState.orders.filter {
                $0.status == .pickedUp || $0.status == .cancelled
            }

            if !active.isEmpty {
                Section("Active") {
                    ForEach(active) { order in
                        NavigationLink(value: order) {
                            OrderRow(order: order)
                        }
                    }
                }
            }

            if !past.isEmpty {
                Section("History") {
                    ForEach(past) { order in
                        NavigationLink(value: order) {
                            OrderRow(order: order)
                        }
                    }
                }
            }
        }
        .navigationDestination(for: Order.self) { order in
            OrderDetailView(order: order)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bag")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No orders yet")
                .font(.headline)
            Text("Your orders will appear here after you place one")
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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(order.basket.store.name)
                    .font(.headline)
                Spacer()
                Label(order.status.displayName, systemImage: order.status.systemImage)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(order.status.color)
            }

            Text(order.basket.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

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
