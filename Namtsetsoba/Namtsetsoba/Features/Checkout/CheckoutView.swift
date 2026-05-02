import SwiftUI

struct CheckoutView: View {
    let basket: Basket
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false
    @State private var completedOrder: Order?
    @State private var checkoutError: String?

    var body: some View {
        NavigationStack {
            Group {
                if let order = completedOrder {
                    confirmationView(order)
                } else {
                    checkoutForm
                }
            }
            .navigationTitle(completedOrder != nil ? "Confirmed!" : "Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if completedOrder == nil {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
            .alert("Checkout failed", isPresented: Binding(
                get: { checkoutError != nil },
                set: { if !$0 { checkoutError = nil } }
            )) {
                Button("OK", role: .cancel) { checkoutError = nil }
            } message: {
                if let checkoutError {
                    Text(checkoutError)
                }
            }
        }
    }

    // MARK: - Checkout Form

    private var checkoutForm: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Order Summary")
                    .font(.headline)

                HStack {
                    VStack(alignment: .leading) {
                        Text(basket.title)
                            .font(.subheadline.weight(.medium))
                        Text(basket.store.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(Utilities.formatMoneyGel(basket.discountedPrice))
                        .font(.headline)
                }

                Divider()

                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text(Utilities.formatMoneyGel(basket.discountedPrice))
                        .font(.title2.bold())
                        .foregroundStyle(DesignTokens.primaryGreen)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))

            VStack(alignment: .leading, spacing: 8) {
                Label("Pickup", systemImage: "clock.fill")
                    .font(.headline)
                Text(Utilities.formatPickupWindow(
                    start: basket.pickupStartTime,
                    end: basket.pickupEndTime
                ))
                .font(.subheadline)
                Text(basket.store.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))

            Spacer()

            Button { processPayment() } label: {
                Group {
                    if isProcessing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Pay \(Utilities.formatMoneyGel(basket.discountedPrice))")
                    }
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    DesignTokens.primaryGreen,
                    in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                )
            }
            .disabled(isProcessing)

            Text("Demo mode — no real payment will be processed")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    // MARK: - Confirmation

    private func confirmationView(_ order: Order) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(DesignTokens.primaryGreen)

            Text("Order Confirmed!")
                .font(.title.bold())

            Text("Show this code when you pick up your order")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text(order.pickupCode)
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))

            VStack(spacing: 8) {
                Text(basket.store.name)
                    .font(.headline)
                Text(Utilities.formatPickupWindow(
                    start: basket.pickupStartTime,
                    end: basket.pickupEndTime
                ))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Button { dismiss() } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        DesignTokens.primaryGreen,
                        in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                    )
            }
        }
        .padding()
    }

    // MARK: - Payment Logic

    private func processPayment() {
        isProcessing = true
        checkoutError = nil
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))

            guard let userId = appState.userId else {
                checkoutError = "Not logged in."
                isProcessing = false
                return
            }

            let pickupCode = String(format: "%04d", Int.random(in: 1000...9999))

            do {
                try await OrderService.shared.createOrder(
                    userId: userId,
                    basketId: basket.id,
                    totalPaid: basket.discountedPrice,
                    pickupCode: pickupCode
                )
                try await BasketService.shared.decrementRemainingCount(basketId: basket.id)
                appState.frequentStoreIds.insert(basket.store.id)
                await appState.loadOrders()
                await appState.loadNotifications()
                appState.triggerBasketRefresh()

                guard let synced = appState.orders.first(where: { $0.pickupCode == pickupCode }) else {
                    checkoutError = "Payment recorded but order could not be loaded. Pull to refresh on Orders."
                    isProcessing = false
                    return
                }

                withAnimation {
                    completedOrder = synced
                    isProcessing = false
                }
            } catch {
                checkoutError = error.localizedDescription
                print("⚠️ Checkout failed: \(error)")
                isProcessing = false
            }
        }
    }
}

#Preview {
    CheckoutView(basket: MockData.baskets[0])
        .environment(AppState())
}
