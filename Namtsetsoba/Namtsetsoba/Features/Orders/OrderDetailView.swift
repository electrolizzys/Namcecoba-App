import SwiftUI

struct OrderDetailView: View {
    let order: Order

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                statusCard
                pickupCodeCard
                basketInfoCard
                storeCard
                paymentCard
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
            Image(systemName: order.status.systemImage)
                .font(.title)
                .foregroundStyle(order.status.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(order.status.displayName)
                    .font(.title3.bold())
                    .foregroundStyle(order.status.color)
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

            if order.status == .confirmed || order.status == .readyForPickup {
                Text("Show this code at the store")
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
            Label("What you ordered", systemImage: "bag.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(order.basket.title)
                .font(.headline)

            Text(order.basket.itemsDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if order.status == .confirmed || order.status == .readyForPickup {
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

    // MARK: - Store

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
            HStack {
                Text("Total paid")
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
    }
}
