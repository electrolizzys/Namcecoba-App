import SwiftUI

struct BusinessHomeView: View {
    @Environment(AppState.self) private var appState
    @State private var showAddBasket = false
    @State private var editingBasket: Basket?

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
            .sheet(isPresented: $showAddBasket, onDismiss: {
                Task { await reloadBusinessBaskets() }
            }) {
                AddBasketForm(store: appState.businessStore, editingBasket: nil)
            }
            .sheet(item: $editingBasket, onDismiss: {
                Task { await reloadBusinessBaskets() }
            }) { basket in
                AddBasketForm(store: appState.businessStore, editingBasket: basket)
            }
            .onChange(of: appState.businessStore.logoURL) { _, _ in
                Task { await reloadBusinessBaskets() }
            }
        }
    }

    @MainActor
    private func reloadBusinessBaskets() async {
        let baskets = await BasketService.shared.fetchBusinessBaskets(storeId: appState.businessStore.id)
        appState.businessBaskets = baskets
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
                    BusinessBasketCard(
                        basket: basket,
                        onEdit: { editingBasket = basket },
                        onRemove: {
                            Task {
                                do {
                                    try await BasketService.shared.deleteBasket(id: basket.id)
                                    await MainActor.run {
                                        withAnimation { appState.removeBasket(basket) }
                                    }
                                } catch {
                                    print("⚠️ Delete basket failed: \(error.localizedDescription)")
                                }
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Business Basket Card

struct BusinessBasketCard: View {
    @Environment(AppState.self) private var appState
    let basket: Basket
    let onEdit: () -> Void
    let onRemove: () -> Void

    private var displayStore: Store {
        guard basket.store.id == appState.businessStore.id else { return basket.store }
        return appState.businessStore
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                StoreThumbnailView(store: displayStore, size: 56)
                    .id("\(displayStore.id.uuidString)-\(displayStore.logoURL ?? "")")

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
                    Button {
                        onEdit()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        onRemove()
                    } label: {
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
    var editingBasket: Basket?
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

    private var isEditing: Bool { editingBasket != nil }

    private var isValid: Bool {
        !title.isEmpty &&
        !itemsDescription.isEmpty &&
        Decimal(string: originalPrice.replacingOccurrences(of: ",", with: ".")) != nil &&
        Decimal(string: discountedPrice.replacingOccurrences(of: ",", with: ".")) != nil
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
                    Stepper(
                        isEditing ? "Remaining for sale: \(availableCount)" : "Available baskets: \(availableCount)",
                        value: $availableCount,
                        in: isEditing ? 0...50 : 1...50
                    )
                }
            }
            .navigationTitle(isEditing ? "Edit Basket" : "New Basket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Publish") { saveBasket() }
                        .bold()
                        .disabled(!isValid)
                }
            }
            .onAppear {
                populateFromEditingBasketIfNeeded()
            }
        }
    }

    private func populateFromEditingBasketIfNeeded() {
        guard let b = editingBasket else { return }
        title = b.title
        description = b.description
        itemsDescription = b.itemsDescription
        originalPrice = Self.priceFieldString(b.originalPrice)
        discountedPrice = Self.priceFieldString(b.discountedPrice)
        pickupStart = b.pickupStartTime
        pickupEnd = b.pickupEndTime
        availableCount = b.remainingCount
    }

    private static func priceFieldString(_ amount: Decimal) -> String {
        String(format: "%.2f", NSDecimalNumber(decimal: amount).doubleValue)
    }

    private func parsedDecimals() -> (Decimal, Decimal)? {
        let origStr = originalPrice.replacingOccurrences(of: ",", with: ".")
        let discStr = discountedPrice.replacingOccurrences(of: ",", with: ".")
        guard let o = Decimal(string: origStr), let d = Decimal(string: discStr) else { return nil }
        return (o, d)
    }

    private func saveBasket() {
        guard let (origPrice, discPrice) = parsedDecimals() else { return }

        Task { @MainActor in
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime]

            do {
                if let existing = editingBasket {
                    let upd = BasketService.BasketUpdate(
                        title: title,
                        description: description,
                        originalPrice: NSDecimalNumber(decimal: origPrice).doubleValue,
                        discountedPrice: NSDecimalNumber(decimal: discPrice).doubleValue,
                        pickupStartTime: isoFormatter.string(from: pickupStart),
                        pickupEndTime: isoFormatter.string(from: pickupEnd),
                        itemsDescription: itemsDescription,
                        remainingCount: max(0, availableCount)
                    )
                    try await BasketService.shared.updateBasket(id: existing.id, update: upd)
                } else {
                    let insert = BasketService.BasketInsert(
                        storeId: store.id,
                        title: title,
                        description: description,
                        originalPrice: NSDecimalNumber(decimal: origPrice).doubleValue,
                        discountedPrice: NSDecimalNumber(decimal: discPrice).doubleValue,
                        pickupStartTime: isoFormatter.string(from: pickupStart),
                        pickupEndTime: isoFormatter.string(from: pickupEnd),
                        itemsDescription: itemsDescription,
                        remainingCount: max(1, availableCount)
                    )
                    try await BasketService.shared.createBasket(insert)
                }
                appState.triggerBasketRefresh()
                dismiss()
            } catch {
                print("⚠️ Save basket failed: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    BusinessHomeView()
        .environment(AppState())
}
