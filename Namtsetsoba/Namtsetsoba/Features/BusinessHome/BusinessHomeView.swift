import SwiftUI

struct BusinessHomeView: View {
    @Environment(AppState.self) private var appState
    @State private var showAddBasket = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.padding) {
                    addBasketButton
                    activeBasketsList
                }
                .padding(.horizontal, DesignTokens.padding)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("My Products")
            .task {
                await reloadBusinessBaskets()
            }
            .refreshable {
                await reloadBusinessBaskets()
            }
            .sheet(isPresented: $showAddBasket) {
                AddBasketForm(store: appState.businessStore)
            }
        }
    }

    private func reloadBusinessBaskets() async {
        appState.businessBaskets = await BasketService.shared.fetchBusinessBaskets(storeId: appState.businessStore.id)
    }

    // MARK: - Add Basket Button

    private var addBasketButton: some View {
        Button { showAddBasket = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(DesignTokens.primaryGreen.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "plus")
                        .font(.title3.bold())
                        .foregroundStyle(DesignTokens.primaryGreen)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Add New Basket")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Create a new offer for customers")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
            .shadow(color: DesignTokens.cardShadowColor, radius: DesignTokens.cardShadowRadius, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Active Baskets

    private var activeBasketsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(
                "Active Baskets (\(appState.businessBaskets.count))",
                systemImage: "storefront.fill"
            )
            .font(.title3.bold())

            if appState.businessBaskets.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("No active baskets")
                        .font(.headline)
                    Text("Tap \"Add New Basket\" to create your first offer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(appState.businessBaskets) { basket in
                    BusinessBasketCard(basket: basket) {
                        withAnimation { appState.removeBasket(basket) }
                        Task { try? await BasketService.shared.deleteBasket(id: basket.id) }
                    }
                }
            }
        }
    }
}

// MARK: - Business Basket Card

struct BusinessBasketCard: View {
    let basket: Basket
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: DesignTokens.smallCornerRadius)
                        .fill(DesignTokens.gradientForCategory(basket.store.category))
                        .frame(width: 56, height: 56)
                    Text(basket.store.category.icon)
                        .font(.title2)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(basket.title)
                        .font(.headline)
                    Text(basket.itemsDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Menu {
                    Button(role: .destructive) { onRemove() } label: {
                        Label("Remove", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(8)
                }
            }

            Divider()

            HStack {
                Label(
                    Utilities.formatPickupWindow(
                        start: basket.pickupStartTime,
                        end: basket.pickupEndTime
                    ),
                    systemImage: "clock"
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                Spacer()

                Text("\(basket.remainingCount) left")
                    .font(.caption.bold())
                    .foregroundStyle(basket.remainingCount <= 2 ? .red : DesignTokens.primaryGreen)
            }

            HStack {
                HStack(spacing: 6) {
                    Text(Utilities.formatMoneyGel(basket.originalPrice))
                        .font(.subheadline)
                        .strikethrough()
                        .foregroundStyle(.secondary)
                    Text(Utilities.formatMoneyGel(basket.discountedPrice))
                        .font(.headline.bold())
                        .foregroundStyle(DesignTokens.primaryGreen)
                }

                Spacer()

                Text("-\(basket.savingsPercent)%")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(DesignTokens.primaryGreen, in: Capsule())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .shadow(color: DesignTokens.cardShadowColor, radius: DesignTokens.cardShadowRadius, y: 4)
    }
}

// MARK: - Add Basket Form

struct AddBasketForm: View {
    let store: Store
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var itemsDescription = ""
    @State private var originalPrice = ""
    @State private var discountedPrice = ""
    @State private var pickupStart = Date().addingTimeInterval(3600)
    @State private var pickupEnd = Date().addingTimeInterval(3600 * 3)
    @State private var availableCount = 5

    private var isValid: Bool {
        !title.isEmpty &&
        !itemsDescription.isEmpty &&
        Decimal(string: originalPrice) != nil &&
        Decimal(string: discountedPrice) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basket Info") {
                    TextField("Title (e.g. Surprise Bread Basket)", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...5)
                    TextField("What's inside (e.g. Bread, croissants, pastries)", text: $itemsDescription)
                }

                Section("Pricing") {
                    HStack {
                        Text("Original price")
                        Spacer()
                        TextField("0.00", text: $originalPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("₾")
                    }
                    HStack {
                        Text("Discounted price")
                        Spacer()
                        TextField("0.00", text: $discountedPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("₾")
                    }
                }

                Section("Pickup Window") {
                    DatePicker("From", selection: $pickupStart, displayedComponents: [.hourAndMinute])
                    DatePicker("Until", selection: $pickupEnd, displayedComponents: [.hourAndMinute])
                }

                Section("Availability") {
                    Stepper("Available baskets: \(availableCount)", value: $availableCount, in: 1...50)
                }
            }
            .navigationTitle("New Basket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Publish") { publishBasket() }
                        .bold()
                        .disabled(!isValid)
                }
            }
        }
    }

    private func publishBasket() {
        guard let origPrice = Decimal(string: originalPrice),
              let discPrice = Decimal(string: discountedPrice) else { return }

        let basket = Basket(
            id: UUID(),
            store: store,
            title: title,
            description: description,
            originalPrice: origPrice,
            discountedPrice: discPrice,
            pickupStartTime: pickupStart,
            pickupEndTime: pickupEnd,
            itemsDescription: itemsDescription,
            remainingCount: availableCount,
            distanceKm: nil
        )
        appState.publishBasket(basket)

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        let insert = BasketService.BasketInsert(
            storeId: store.id,
            title: title,
            description: description,
            originalPrice: NSDecimalNumber(decimal: origPrice).doubleValue,
            discountedPrice: NSDecimalNumber(decimal: discPrice).doubleValue,
            pickupStartTime: isoFormatter.string(from: pickupStart),
            pickupEndTime: isoFormatter.string(from: pickupEnd),
            itemsDescription: itemsDescription,
            remainingCount: availableCount
        )
        Task { try? await BasketService.shared.createBasket(insert) }

        dismiss()
    }
}

#Preview {
    BusinessHomeView()
        .environment(AppState())
}
