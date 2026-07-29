import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(AppState.self) private var appState
    @Environment(LocationManager.self) private var locationManager
    @State private var showMap = false
    @State private var selectedBasket: Basket?

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            VStack(spacing: 0) {
                AppListControlsHeader(
                    searchPlaceholder: L(.offersSearchPlaceholder),
                    searchText: $viewModel.searchQuery,
                    sortLabel: viewModel.selectedSort.localizedName,
                    selectedCategory: $viewModel.selectedCategory
                ) {
                    ForEach(SortOption.allCases) { option in
                        Button {
                            viewModel.selectedSort = option
                        } label: {
                            Label(option.localizedName, systemImage: option.systemImage)
                        }
                    }
                }
                .zIndex(1)

                ScrollView {
                    VStack(spacing: DesignTokens.padding) {
                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.top, 60)
                        } else if viewModel.filteredBaskets.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredBaskets) { basket in
                                    Button {
                                        selectedBasket = basket
                                    } label: {
                                        BasketCard(basket: basket)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DesignTokens.padding)
                    .padding(.bottom, 24)
                    .floatingTabBarScrollFiller()
                }
                .background(DesignTokens.selectedChipBackground)
            }
            .navigationTitle("Namtsetsoba")
            .brandedListScreenStyle()
            .toolbar(.hidden, for: .tabBar)
            .mapExploreToolbarItem(isPresented: $showMap)
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
            .navigationDestination(item: $selectedBasket) { basket in
                BasketDetailView(basket: basket)
            }
            .onTabRootReset {
                selectedBasket = nil
                showMap = false
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


    private var emptyState: some View {
        AppEmptyState(
            icon: "magnifyingglass",
            title: L(.offersEmptyTitle),
            message: L(.offersEmptyMessage)
        )
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
            StoreBannerImage(store: basket.store, height: 130)
                .overlay {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
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
                    Text(basket.store.displayRatingText)
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
