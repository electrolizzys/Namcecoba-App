import SwiftUI

struct OrdersView: View {
    @Environment(AppState.self) private var appState
    @State private var searchCode = ""
    @State private var isMarkingAll = false

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
            .refreshable {
                await appState.loadOrders()
                await appState.loadNotifications()
            }
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
        let confirmedOnly = current.filter { $0.status == .confirmed }

        let filteredCurrent: [Order] = {
            guard !searchCode.isEmpty else { return current }
            return current.filter {
                $0.pickupCode.localizedCaseInsensitiveContains(searchCode)
            }
        }()

        return List {
            if !current.isEmpty {
                Section {
                    ForEach(filteredCurrent) { order in
                        NavigationLink(value: order) {
                            OrderRow(order: order, isStoreView: true)
                        }
                    }
                } header: {
                    Text(searchCode.isEmpty ? "Current Orders (\(current.count))" : "Current Orders")
                } footer: {
                    if searchCode.isEmpty, !confirmedOnly.isEmpty {
                        Button {
                            markAllAsReady(confirmedOnly)
                        } label: {
                            HStack {
                                if isMarkingAll {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                                Text(confirmedOnly.count == 1 ? "Mark as Ready" : "Mark All as Ready (\(confirmedOnly.count))")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(DesignTokens.primaryGreen, in: RoundedRectangle(cornerRadius: 10))
                        }
                        .disabled(isMarkingAll)
                        .padding(.top, 8)
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
        .searchable(text: $searchCode, prompt: "Search by pickup code")
        .navigationDestination(for: Order.self) { order in
            OrderDetailView(order: order)
        }
    }

    private func markAllAsReady(_ orders: [Order]) {
        isMarkingAll = true
        Task {
            for order in orders {
                try? await OrderService.shared.updateOrderStatus(
                    orderId: order.id,
                    status: OrderStatus.readyForPickup.rawValue
                )
                if let idx = appState.storeOrders.firstIndex(where: { $0.id == order.id }) {
                    appState.storeOrders[idx].status = .readyForPickup
                }
            }
            isMarkingAll = false
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
