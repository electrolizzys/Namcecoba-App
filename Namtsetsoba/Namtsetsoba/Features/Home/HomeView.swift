import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignTokens.padding) {
                    sortPicker
                    categoryFilter

                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.top, 60)
                    } else if viewModel.filteredBaskets.isEmpty {
                        emptyState
                    } else {
                        basketSection(
                            title: "Offers",
                            icon: "leaf.fill",
                            tint: .primary,
                            baskets: viewModel.filteredBaskets
                        )
                    }
                }
                .padding(.horizontal, DesignTokens.padding)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Offers")
            .searchable(text: $viewModel.searchQuery, prompt: "Search by store name")
            .refreshable { await viewModel.loadBaskets() }
            .task {
                viewModel.frequentStoreIds = appState.frequentStoreIds
                if viewModel.allBaskets.isEmpty {
                    await viewModel.loadBaskets()
                }
            }
            .onChange(of: appState.frequentStoreIds) { _, newValue in
                viewModel.frequentStoreIds = newValue
            }
            .navigationDestination(for: Basket.self) { basket in
                BasketDetailView(basket: basket)
            }
        }
    }


    private var sortPicker: some View {
        Menu {
            ForEach(SortOption.allCases) { option in
                Button {
                    viewModel.selectedSort = option
                } label: {
                    Label(option.rawValue, systemImage: option.systemImage)
                }
            }
        } label: {
            HStack {
                Image(systemName: viewModel.selectedSort.systemImage)
                Text(viewModel.selectedSort.rawValue)
                    .font(.subheadline.weight(.medium))
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                categoryChip(nil, label: "All")
                ForEach(ProductCategory.allCases) { category in
                    categoryChip(category, label: "\(category.icon) \(category.rawValue)")
                }
            }
        }
    }

    private func categoryChip(_ category: ProductCategory?, label: String) -> some View {
        let isSelected = viewModel.selectedCategory == category
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedCategory = category
            }
        } label: {
            Text(label)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected
                        ? AnyShapeStyle(DesignTokens.primaryGreen)
                        : AnyShapeStyle(Color(.secondarySystemBackground))
                )
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }


    private func basketSection(
        title: String,
        icon: String,
        tint: Color,
        baskets: [Basket]
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.title3.bold())
                .foregroundStyle(tint)

            ForEach(baskets) { basket in
                NavigationLink(value: basket) {
                    BasketCard(basket: basket)
                }
                .buttonStyle(.plain)
            }
        }
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
                if let distance = basket.distanceKm {
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
}
