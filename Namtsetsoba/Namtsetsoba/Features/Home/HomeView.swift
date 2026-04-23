import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(AppState.self) private var appState
    @Environment(LocationManager.self) private var locationManager
    @State private var showMap = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.padding) {
                    filterRow

                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 60)
                    } else if viewModel.filteredBaskets.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredBaskets) { basket in
                                NavigationLink(value: basket) {
                                    BasketCard(basket: basket)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, DesignTokens.padding)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Namtsetsoba")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showMap = true
                    } label: {
                        Image(systemName: "map.fill")
                            .foregroundStyle(DesignTokens.primaryGreen)
                    }
                }
            }
            .fullScreenCover(isPresented: $showMap) {
                MapExploreView()
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search by store name")
            .refreshable { await viewModel.loadBaskets() }
            .task {
                viewModel.frequentStoreIds = appState.frequentStoreIds
                if viewModel.allBaskets.isEmpty {
                    await viewModel.loadBaskets()
                }
            }
            .onAppear {
                viewModel.frequentStoreIds = appState.frequentStoreIds
                viewModel.userLocation = locationManager.userLocation
            }
            .onChange(of: locationManager.userLocation?.latitude) { _, _ in
                viewModel.userLocation = locationManager.userLocation
            }
            .onChange(of: appState.frequentStoreIds) { _, newValue in
                viewModel.frequentStoreIds = newValue
            }
            .onChange(of: appState.basketRefreshTrigger) { _, _ in
                Task { await viewModel.loadBaskets() }
            }
            .navigationDestination(for: Basket.self) { basket in
                BasketDetailView(basket: basket)
            }
        }
    }


    // MARK: - Store Bar

    private var storeBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.availableStores, id: \.id) { store in
                    storeChip(store)
                }
            }
        }
    }

    private func storeChip(_ store: Store) -> some View {
        let isSelected = viewModel.selectedStoreId == store.id
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isSelected {
                    viewModel.selectedStoreId = nil
                } else {
                    viewModel.selectedStoreId = store.id
                }
            }
        } label: {
            Text(store.name)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    isSelected
                        ? AnyShapeStyle(DesignTokens.primaryGreen)
                        : AnyShapeStyle(Color(.secondarySystemBackground))
                )
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }

    // MARK: - Filter Row

    private var filterRow: some View {
        HStack(spacing: 12) {
            dropdownButton(
                icon: "arrow.up.arrow.down",
                label: viewModel.selectedSort.rawValue
            ) {
                Button {
                    viewModel.selectedSort = .price
                } label: {
                    Label("All", systemImage: "square.grid.2x2")
                }
                Divider()
                ForEach(SortOption.allCases) { option in
                    Button {
                        viewModel.selectedSort = option
                    } label: {
                        Label(option.rawValue, systemImage: option.systemImage)
                    }
                }
            }

            dropdownButton(
                icon: "line.3.horizontal.decrease",
                label: viewModel.selectedCategory?.rawValue ?? "All Types"
            ) {
                Button {
                    viewModel.selectedCategory = nil
                } label: {
                    Label("All Types", systemImage: "square.grid.2x2")
                }
                ForEach(ProductCategory.allCases) { category in
                    Button {
                        viewModel.selectedCategory = category
                    } label: {
                        Label("\(category.icon) \(category.rawValue)", systemImage: "tag")
                    }
                }
            }
        }
    }

    private func dropdownButton<Content: View>(
        icon: String,
        label: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        Menu {
            content()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Spacer(minLength: 0)
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
    }


    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No offers found")
                .font(.headline)
            Text("Try adjusting your filters or search")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 60)
    }
}


struct BasketCard: View {
    let basket: Basket

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerImage
            cardDetails
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .shadow(color: DesignTokens.cardShadowColor, radius: DesignTokens.cardShadowRadius, y: 4)
    }

    private var headerImage: some View {
        ZStack {
            DesignTokens.gradientForCategory(basket.store.category)
                .frame(height: 130)
                .overlay {
                    Text(basket.store.category.icon)
                        .font(.system(size: 56))
                        .opacity(0.25)
                }

            VStack {
                HStack {
                    Text("-\(basket.savingsPercent)%")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.black.opacity(0.5), in: Capsule())

                    Spacer()

                    if basket.remainingCount <= 3 {
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                            Text("\(basket.remainingCount) left")
                        }
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.red.opacity(0.85), in: Capsule())
                    }
                }

                Spacer()

                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                        Text(Utilities.formatPickupWindow(
                            start: basket.pickupStartTime,
                            end: basket.pickupEndTime
                        ))
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.4), in: Capsule())

                    Spacer()
                }
            }
            .padding(10)
        }
    }

    private var cardDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(basket.store.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.orange)
                    Text(String(format: "%.1f", basket.store.rating))
                }
                .font(.caption.weight(.medium))
            }

            Text(basket.title)
                .font(.headline)
                .foregroundStyle(.primary)

            HStack {
                if let distance = LocationManager.shared.distanceToStore(basket.store) {
                    Label(
                        String(format: "%.1f km", distance),
                        systemImage: "location.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 6) {
                    Text(Utilities.formatMoneyGel(basket.originalPrice))
                        .font(.subheadline)
                        .strikethrough()
                        .foregroundStyle(.secondary)
                    Text(Utilities.formatMoneyGel(basket.discountedPrice))
                        .font(.headline.bold())
                        .foregroundStyle(DesignTokens.primaryGreen)
                }
            }
        }
        .padding(DesignTokens.padding)
    }
}

#Preview {
    HomeView()
        .environment(AppState())
        .environment(LocationManager.shared)
}
