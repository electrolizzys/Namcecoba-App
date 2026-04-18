import SwiftUI

struct StoresListView: View {
    @Environment(AppState.self) private var appState
    @State private var allStores: [Store] = []
    @State private var searchQuery = ""
    @State private var selectedCategory: ProductCategory?
    @State private var selectedSort: StoreSortOption = .rating
    @State private var showFavouritesOnly = false
    @State private var isLoading = false

    var filteredStores: [Store] {
        var result = allStores

        if !searchQuery.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery) ||
                $0.address.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if showFavouritesOnly {
            result = result.filter { appState.isFavourite($0.id) }
        }

        switch selectedSort {
        case .rating:
            result.sort { $0.rating > $1.rating }
        case .name:
            result.sort { $0.name < $1.name }
        case .openNow:
            result.sort { lhs, rhs in
                if lhs.isOpenNow != rhs.isOpenNow { return lhs.isOpenNow }
                return lhs.rating > rhs.rating
            }
        case .distance:
            result.sort {
                (LocationManager.shared.distanceToStore($0) ?? .infinity) <
                (LocationManager.shared.distanceToStore($1) ?? .infinity)
            }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.padding) {
                    filterRow

                    if isLoading {
                        ProgressView()
                            .padding(.top, 60)
                    } else if filteredStores.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredStores) { store in
                                NavigationLink(value: store) {
                                    StoreListCard(store: store)
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
            .navigationTitle("Stores")
            .searchable(text: $searchQuery, prompt: "Search stores")
            .refreshable { await loadStores() }
            .task {
                if allStores.isEmpty { await loadStores() }
            }
            .navigationDestination(for: Store.self) { store in
                StoreDetailView(store: store)
            }
        }
    }

    private var filterRow: some View {
        HStack(spacing: 12) {
            Menu {
                Button {
                    showFavouritesOnly = false
                } label: {
                    Label("All Stores", systemImage: "square.grid.2x2")
                }
                Divider()
                ForEach(StoreSortOption.allCases) { option in
                    Button {
                        showFavouritesOnly = false
                        selectedSort = option
                    } label: {
                        Label(option.rawValue, systemImage: option.systemImage)
                    }
                }
                Divider()
                Button {
                    showFavouritesOnly = true
                } label: {
                    Label("Your Favorites", systemImage: "heart.fill")
                }
            } label: {
                filterLabel(
                    icon: "arrow.up.arrow.down",
                    text: showFavouritesOnly ? "Favourites" : selectedSort.rawValue
                )
            }

            Menu {
                Button {
                    selectedCategory = nil
                } label: {
                    Label("All Types", systemImage: "square.grid.2x2")
                }
                ForEach(ProductCategory.allCases) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Label("\(category.icon) \(category.rawValue)", systemImage: "tag")
                    }
                }
            } label: {
                filterLabel(icon: "line.3.horizontal.decrease", text: selectedCategory?.rawValue ?? "All Types")
            }
        }
    }

    private func filterLabel(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.subheadline)
            Text(text).font(.subheadline.weight(.medium)).lineLimit(1)
            Spacer(minLength: 0)
            Image(systemName: "chevron.down").font(.caption2.weight(.semibold))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
        .frame(maxWidth: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "storefront")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No stores found")
                .font(.headline)
            Text("Try adjusting your filters or search")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 60)
    }

    private func loadStores() async {
        isLoading = allStores.isEmpty
        allStores = await StoreService.shared.fetchStores()
        isLoading = false
    }
}

// MARK: - Sort Option

enum StoreSortOption: String, CaseIterable, Identifiable {
    case rating = "Top Rated"
    case name = "Name"
    case openNow = "Open Now"
    case distance = "Distance"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .rating: "star.fill"
        case .name: "textformat"
        case .openNow: "clock.fill"
        case .distance: "location.fill"
        }
    }
}

// MARK: - Store List Card

struct StoreListCard: View {
    let store: Store
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.smallCornerRadius)
                    .fill(DesignTokens.gradientForCategory(store.category))
                    .frame(width: 60, height: 60)
                Text(store.category.icon)
                    .font(.title2)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(store.name)
                        .font(.headline)
                    if appState.isFavourite(store.id) {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    Spacer()
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.orange)
                        Text(String(format: "%.1f", store.rating))
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
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .shadow(color: DesignTokens.cardShadowColor, radius: DesignTokens.cardShadowRadius, y: 4)
    }
}

#Preview {
    StoresListView()
        .environment(AppState())
}
