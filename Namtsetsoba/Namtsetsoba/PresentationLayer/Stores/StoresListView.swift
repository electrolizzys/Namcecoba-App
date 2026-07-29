import SwiftUI

struct StoresListView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = StoresListViewModel()
    @State private var selectedStore: Store?
    @State private var showMap = false

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            VStack(spacing: 0) {
                AppListControlsHeader(
                    searchPlaceholder: L(.storesSearchPlaceholder),
                    searchText: $viewModel.searchQuery,
                    sortLabel: viewModel.sortLabel,
                    selectedCategory: $viewModel.selectedCategory
                ) {
                    Button {
                        viewModel.showFavouritesOnly = false
                    } label: {
                        Label("All Stores", systemImage: "square.grid.2x2")
                    }
                    Divider()
                    ForEach(StoreSortOption.allCases) { option in
                        Button {
                            viewModel.showFavouritesOnly = false
                            viewModel.selectedSort = option
                        } label: {
                            Label(option.localizedName, systemImage: option.systemImage)
                        }
                    }
                    Divider()
                    Button {
                        viewModel.showFavouritesOnly = true
                    } label: {
                        Label("Your Favorites", systemImage: "heart.fill")
                    }
                }
                .zIndex(1)

                ScrollView {
                    VStack(spacing: DesignTokens.padding) {
                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.top, 60)
                        } else if viewModel.filteredStores.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.filteredStores) { store in
                                    Button {
                                        selectedStore = store
                                    } label: {
                                        StoreListCard(store: store)
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
            .navigationTitle(L(.storesTitle))
            .brandedListScreenStyle()
            .toolbar(.hidden, for: .tabBar)
            .mapExploreToolbarItem(isPresented: $showMap)
            .refreshable { await viewModel.loadStores() }
            .task {
                viewModel.favouriteStoreIds = appState.frequentStoreIds
                if viewModel.allStores.isEmpty { await viewModel.loadStores() }
            }
            .onChange(of: appState.frequentStoreIds) { _, ids in
                viewModel.favouriteStoreIds = ids
            }
            .navigationDestination(item: $selectedStore) { store in
                StoreDetailView(store: store)
            }
            .onTabRootReset {
                selectedStore = nil
                showMap = false
            }
        }
    }

    private var emptyState: some View {
        AppEmptyState(
            icon: "storefront",
            title: L(.storesEmptyTitle),
            message: L(.storesEmptyMessage)
        )
    }
}

// MARK: - Store List Card

struct StoreListCard: View {
    let store: Store
    @Environment(AppState.self) private var appState

    var body: some View {
        AppCard {
            HStack(spacing: 14) {
                StoreThumbnailView(store: store, size: 60)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(store.name)
                            .font(.headline)
                        if appState.currentRole == .customer, appState.isFavourite(store.id) {
                            Image(systemName: "heart.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        Spacer()
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.orange)
                            Text(store.displayRatingText)
                                .fontWeight(.medium)
                        }
                        .font(.caption)
                    }

                    Text(store.address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    HStack(spacing: 12) {
                        Label(store.category.rawValue, systemImage: "tag")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 4) {
                            Circle()
                                .fill(store.isOpenNow ? .green : .red)
                                .frame(width: 6, height: 6)
                            Text(store.isOpenNow ? "Open" : "Closed")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(store.isOpenNow ? .green : .red)
                        }

                        Text("\(store.openTime) – \(store.closeTime)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        if let dist = LocationManager.shared.distanceToStore(store) {
                            Text(String(format: "%.1f km", dist))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
