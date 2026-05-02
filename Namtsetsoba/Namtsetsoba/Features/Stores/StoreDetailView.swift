import SwiftUI
import MapKit

struct StoreDetailView: View {
    let store: Store
    @Environment(AppState.self) private var appState
    @State private var baskets: [Basket] = []
    @State private var isLoading = true
    @State private var showFullMap = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroHeader
                VStack(spacing: 16) {
                    infoCard
                    hoursCard
                    locationCard
                    favouriteCard
                    basketsSection
                }
                .padding(DesignTokens.padding)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(store.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadBaskets() }
        .refreshable { await loadBaskets() }
    }

    // MARK: - Hero

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            StoreBannerImage(store: store, height: 180)
                .overlay {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.55)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(store.isOpenNow ? .green : .red)
                        .frame(width: 8, height: 8)
                    Text(store.isOpenNow ? "Open Now" : "Closed")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.black.opacity(0.4), in: Capsule())

                Text(store.name)
                    .font(.title.bold())
                    .foregroundStyle(.white)
            }
            .padding()
        }
    }

    // MARK: - Info

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(store.address, systemImage: "mappin.circle.fill")
                    .font(.subheadline)
                Spacer()
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.orange)
                    Text(String(format: "%.1f", store.rating))
                        .fontWeight(.bold)
                }
                .font(.subheadline)
            }

            Label(store.category.rawValue, systemImage: "tag.fill")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
    }

    // MARK: - Hours

    private var hoursCard: some View {
        HStack {
            Label("Working Hours", systemImage: "clock.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(store.openTime) – \(store.closeTime)")
                .font(.subheadline.weight(.medium))
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
    }

    // MARK: - Location Map

    private var storeCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
    }

    private var locationCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Location", systemImage: "mappin.and.ellipse")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Map(initialPosition: .region(MKCoordinateRegion(
                center: storeCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))) {
                Marker(store.name, coordinate: storeCoordinate)
                    .tint(DesignTokens.primaryGreen)
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.smallCornerRadius))
            .allowsHitTesting(false)
            .overlay {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { showFullMap = true }
            }

            if let dist = LocationManager.shared.distanceToStore(store) {
                Label(String(format: "%.1f km away", dist), systemImage: "location.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .fullScreenCover(isPresented: $showFullMap) {
            StoreMapFullView(store: store)
        }
    }

    // MARK: - Favourite

    private var favouriteCard: some View {
        Button {
            withAnimation(.spring(response: 0.3)) { appState.toggleFavourite(store.id) }
        } label: {
            HStack {
                Label(
                    appState.isFavourite(store.id) ? "Remove from Favourites" : "Add to Favourites",
                    systemImage: appState.isFavourite(store.id) ? "heart.fill" : "heart"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(appState.isFavourite(store.id) ? .red : DesignTokens.primaryGreen)
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Baskets

    private var basketsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Available Offers (\(baskets.count))", systemImage: "leaf.fill")
                .font(.title3.bold())

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else if baskets.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                    Text("No offers available right now")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(baskets) { basket in
                    NavigationLink(value: basket) {
                        BasketCard(basket: basket)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationDestination(for: Basket.self) { basket in
            BasketDetailView(basket: basket)
        }
    }

    private func loadBaskets() async {
        isLoading = baskets.isEmpty
        let allBaskets = await BasketService.shared.fetchAvailableBaskets()
        baskets = allBaskets.filter { $0.store.id == store.id }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        StoreDetailView(store: MockData.stores[0])
    }
    .environment(AppState())
}
