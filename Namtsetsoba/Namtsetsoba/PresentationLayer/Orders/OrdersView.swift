import SwiftUI

struct OrdersView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = OrdersViewModel()
    @State private var isMarkingAll = false
    @State private var navigationPath: [Order] = []
    @State private var showMap = false

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                AppScreenHeader(
                    searchPlaceholder: appState.currentRole == .business
                        ? "Search by store or pickup code"
                        : "Search by store",
                    searchText: $viewModel.searchText
                )
                .zIndex(1)

                Group {
                    if appState.currentRole == .business {
                        storeOrdersContent
                    } else {
                        customerOrdersContent
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .brandedListScreenStyle()
            .navigationTitle(appState.currentRole == .business ? "Incoming Orders" : "Orders")
            .toolbar(.hidden, for: .tabBar)
            .mapExploreToolbarItem(isPresented: $showMap)
            .refreshable {
                await appState.loadOrders()
                await appState.loadNotifications()
            }
        }
        .task {
            await openPendingOrderIfNeeded()
        }
        .onChange(of: appState.pendingOrderNavigationId) { _, _ in
            Task { await openPendingOrderIfNeeded() }
        }
    }

    // MARK: - Customer View

    private var customerOrdersContent: some View {
        Group {
            if viewModel.filtered(appState.orders).isEmpty {
                emptyState(
                    message: viewModel.searchText.isEmpty
                        ? "Your orders will appear here after you place one"
                        : "No orders match your search"
                )
            } else {
                customerOrderList(appState.orders)
            }
        }
    }

    private func customerOrderList(_ orders: [Order]) -> some View {
        let active = viewModel.active(orders)
        let past = viewModel.past(orders)

        return List {
            if !active.isEmpty {
                Section {
                    ForEach(active) { order in
                        NavigationLink(value: order) {
                            OrderRow(order: order, isStoreView: false)
                        }
                    }
                } header: {
                    ordersSectionHeader("Active Orders (\(active.count))")
                }
            }

            if !past.isEmpty {
                DisclosureGroup {
                    ForEach(past) { order in
                        NavigationLink(value: order) {
                            OrderRow(order: order, isStoreView: false)
                        }
                    }
                } label: {
                    Text("Past Orders (\(past.count))")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .navigationDestination(for: Order.self) { order in
            OrderDetailView(order: order)
        }
    }

    // MARK: - Store View

    private var storeOrdersContent: some View {
        Group {
            if viewModel.filtered(appState.storeOrders).isEmpty {
                emptyState(
                    message: viewModel.searchText.isEmpty
                        ? "Orders from customers will appear here"
                        : "No orders match your search"
                )
            } else {
                storeOrderList(appState.storeOrders)
            }
        }
    }

    private func storeOrderList(_ orders: [Order]) -> some View {
        let current = viewModel.active(orders)
        let past = viewModel.past(orders)
        let confirmedOnly = viewModel.confirmed(orders)

        return List {
            if !current.isEmpty {
                Section {
                    ForEach(current) { order in
                        NavigationLink(value: order) {
                            OrderRow(order: order, isStoreView: true)
                        }
                    }
                } header: {
                    ordersSectionHeader("Active Orders (\(current.count))")
                } footer: {
                    if !confirmedOnly.isEmpty {
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
        .scrollContentBackground(.hidden)
        .navigationDestination(for: Order.self) { order in
            OrderDetailView(order: order)
        }
    }

    private func markAllAsReady(_ orders: [Order]) {
        isMarkingAll = true
        Task {
            let succeeded = await viewModel.markAllReady(orders)
            for id in succeeded {
                if let idx = appState.storeOrders.firstIndex(where: { $0.id == id }) {
                    appState.storeOrders[idx].status = .readyForPickup
                }
            }
            isMarkingAll = false
        }
    }

    @MainActor
    private func openPendingOrderIfNeeded() async {
        guard let pendingId = appState.pendingOrderNavigationId else { return }

        var targetOrder = ordersForCurrentRole.first(where: { $0.id == pendingId })
        if targetOrder == nil {
            await appState.loadOrders()
            targetOrder = ordersForCurrentRole.first(where: { $0.id == pendingId })
        }

        guard let targetOrder else {
            appState.pendingOrderNavigationId = nil
            return
        }

        navigationPath = [targetOrder]
        appState.pendingOrderNavigationId = nil
    }

    private var ordersForCurrentRole: [Order] {
        appState.currentRole == .business ? appState.storeOrders : appState.orders
    }

    private func ordersSectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline.bold())
            .foregroundStyle(.primary)
            .textCase(nil)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
