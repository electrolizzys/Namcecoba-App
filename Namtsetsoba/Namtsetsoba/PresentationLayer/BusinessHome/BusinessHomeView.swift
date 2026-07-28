import SwiftUI

struct BusinessHomeView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = BusinessHomeViewModel()
    @State private var showAddBasket = false
    @State private var editingBasket: Basket?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                addBasketButton
                    .padding(.horizontal, DesignTokens.padding)
                    .padding(.vertical, DesignTokens.padding)
                    .background(DesignTokens.primaryGreen)

                ScrollView {
                    activeBasketsList
                        .padding(.horizontal, DesignTokens.padding)
                        .padding(.top, DesignTokens.padding)
                        .padding(.bottom, 24)
                        .floatingTabBarScrollFiller()
                }
                .background(DesignTokens.selectedChipBackground)
            }
            .brandedListScreenStyle()
            .navigationTitle("My Products")
            .toolbar(.hidden, for: .tabBar)
            .refreshable {
                await reloadBusinessBaskets()
            }
            .task {
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
        appState.businessBaskets = await viewModel.loadBaskets(storeId: appState.businessStore.id)
    }

    private func remove(_ basket: Basket) {
        Task { @MainActor in
            do {
                try await viewModel.delete(id: basket.id)
                withAnimation { appState.removeBasket(basket) }
            } catch {
                print("⚠️ Delete basket failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Add Basket Button

    private var addBasketButton: some View {
        Button { showAddBasket = true } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: "plus")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Add New Basket")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Create a new offer for customers")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding()
            .background(Color.white.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
            .contentShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
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
                        onRemove: { remove(basket) }
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
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddBasketFormViewModel

    init(store: Store, editingBasket: Basket?) {
        _viewModel = State(
            initialValue: AddBasketFormViewModel(store: store, editingBasket: editingBasket)
        )
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            Form {
                Section("Basket Info") {
                    TextField("Title (e.g. Surprise Bread Basket)", text: $viewModel.title)
                    TextField("Description", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...5)
                    TextField("What's inside (e.g. Bread, croissants, pastries)", text: $viewModel.itemsDescription)
                }

                Section("Pricing") {
                    HStack {
                        Text("Original price")
                        Spacer()
                        TextField("0.00", text: $viewModel.originalPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("₾")
                    }
                    HStack {
                        Text("Discounted price")
                        Spacer()
                        TextField("0.00", text: $viewModel.discountedPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                        Text("₾")
                    }
                }

                Section("Pickup Window") {
                    DatePicker("From", selection: $viewModel.pickupStart, displayedComponents: [.hourAndMinute])
                    DatePicker("Until", selection: $viewModel.pickupEnd, displayedComponents: [.hourAndMinute])
                }

                Section("Availability") {
                    Stepper(
                        viewModel.isEditing
                            ? "Remaining for sale: \(viewModel.availableCount)"
                            : "Available baskets: \(viewModel.availableCount)",
                        value: $viewModel.availableCount,
                        in: viewModel.availableCountRange
                    )
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Basket" : "New Basket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isEditing ? "Save" : "Publish") { save() }
                        .bold()
                        .disabled(!viewModel.isValid)
                }
            }
        }
    }

    private func save() {
        Task { @MainActor in
            do {
                try await viewModel.save()
                appState.triggerBasketRefresh()
                dismiss()
            } catch {
                print("⚠️ Save basket failed: \(error.localizedDescription)")
            }
        }
    }
}
