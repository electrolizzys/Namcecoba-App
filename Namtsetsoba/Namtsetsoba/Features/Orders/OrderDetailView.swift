import SwiftUI

struct OrderDetailView: View {
    let order: Order
    @Environment(AppState.self) private var appState
    @State private var currentStatus: OrderStatus
    @State private var isUpdating = false

    private var isStoreView: Bool { appState.currentRole == .business }
    private var isActive: Bool { currentStatus == .confirmed || currentStatus == .readyForPickup }

    init(order: Order) {
        self.order = order
        self._currentStatus = State(initialValue: order.status)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                statusCard
                pickupCodeCard
                basketInfoCard
                if !isStoreView {
                    storeCard
                }
                paymentCard
                if isStoreView && isActive {
                    storeActions
                }
            }
            .padding(DesignTokens.padding)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Status

    private var statusCard: some View {
        HStack(spacing: 12) {
            Image(systemName: currentStatus.systemImage)
                .font(.title)
                .foregroundStyle(currentStatus.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(currentStatus.displayName)
                    .font(.title3.bold())
                    .foregroundStyle(currentStatus.color)
                Text(Utilities.formatOrderDate(order.orderDate))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
    }

    // MARK: - Pickup Code

    private var pickupCodeCard: some View {
        VStack(spacing: 12) {
            Text("Pickup Code")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(order.pickupCode)
                .font(.system(size: 44, weight: .bold, design: .monospaced))

            if currentStatus == .confirmed || currentStatus == .readyForPickup {
                Text(isStoreView
                     ? "Customer will show this code"
                     : "Show this code at the store")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
    }

    // MARK: - Basket Info

    private var basketInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(isStoreView ? "Order Contents" : "What you ordered",
                  systemImage: "bag.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(order.basket.title)
                .font(.headline)

            Text(order.basket.itemsDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if currentStatus == .confirmed || currentStatus == .readyForPickup {
                Label(
                    Utilities.formatPickupWindow(
                        start: order.basket.pickupStartTime,
                        end: order.basket.pickupEndTime
                    ),
                    systemImage: "clock.fill"
                )
                .font(.subheadline)
                .foregroundStyle(DesignTokens.primaryGreen)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
    }

    // MARK: - Store (customer only)

    private var storeCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Label("Pickup Location", systemImage: "mappin.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(order.basket.store.name)
                    .font(.headline)
                Text(order.basket.store.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.orange)
                Text(String(format: "%.1f", order.basket.store.rating))
                    .font(.subheadline.bold())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
    }

    // MARK: - Payment

    private var paymentCard: some View {
        VStack(spacing: 12) {
            if !isStoreView {
                HStack {
                    Text("Original price")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(Utilities.formatMoneyGel(order.basket.originalPrice))
                        .strikethrough()
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("You saved")
                        .foregroundStyle(DesignTokens.primaryGreen)
                    Spacer()
                    Text(Utilities.formatMoneyGel(order.basket.originalPrice - order.totalPaid))
                        .foregroundStyle(DesignTokens.primaryGreen)
                        .fontWeight(.medium)
                }
                Divider()
            }
            HStack {
                Text(isStoreView ? "Amount received" : "Total paid")
                    .font(.headline)
                Spacer()
                Text(Utilities.formatMoneyGel(order.totalPaid))
                    .font(.title3.bold())
                    .foregroundStyle(DesignTokens.primaryGreen)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
    }

    // MARK: - Store Actions

    private var storeActions: some View {
        VStack(spacing: 12) {
            if currentStatus == .confirmed {
                actionButton(
                    title: "Mark as Ready for Pickup",
                    icon: "bag.fill.badge.checkmark",
                    color: .blue
                ) {
                    await updateStatus(to: .readyForPickup)
                }
            }

            actionButton(
                title: "Order Picked Up",
                icon: "checkmark.seal.fill",
                color: DesignTokens.primaryGreen
            ) {
                await updateStatus(to: .pickedUp)
            }

            actionButton(
                title: "Cancel Order",
                icon: "xmark.circle.fill",
                color: .red
            ) {
                await updateStatus(to: .cancelled)
            }
        }
    }

    private func actionButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () async -> Void
    ) -> some View {
        Button {
            Task { await action() }
        } label: {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .fontWeight(.semibold)
                if isUpdating {
                    Spacer()
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundStyle(.white)
            .background(color, in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        }
        .disabled(isUpdating)
    }

    private func updateStatus(to newStatus: OrderStatus) async {
        isUpdating = true
        do {
            try await OrderService.shared.updateOrderStatus(
                orderId: order.id,
                status: newStatus.rawValue
            )
            currentStatus = newStatus
            if let idx = appState.storeOrders.firstIndex(where: { $0.id == order.id }) {
                appState.storeOrders[idx].status = newStatus
            }
        } catch {
            print("⚠️ Failed to update order: \(error.localizedDescription)")
        }
        isUpdating = false
    }
}

#Preview {
    NavigationStack {
        OrderDetailView(order: Order(
            id: UUID(),
            basket: MockData.baskets[0],
            status: .confirmed,
            pickupCode: "4821",
            orderDate: Date(),
            totalPaid: 5.99
        ))
        .environment(AppState())
    }
}
