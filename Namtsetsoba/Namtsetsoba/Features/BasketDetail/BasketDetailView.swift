import SwiftUI
import MapKit

struct BasketDetailView: View {
    let basket: Basket
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var showCheckout = false
    @State private var showFullMap = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroHeader
                detailSections
            }
        }
        .background(Color(.systemGroupedBackground))
        .safeAreaInset(edge: .bottom) { orderBar }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCheckout, onDismiss: {
            dismiss()
        }) {
            CheckoutView(basket: basket)
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            DesignTokens.gradientForCategory(basket.store.category)
                .frame(height: 200)
                .overlay {
                    Text(basket.store.category.icon)
                        .font(.system(size: 80))
                        .opacity(0.2)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(basket.store.category.rawValue.uppercased())
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.8))
                Text(basket.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
            .padding()
        }
    }

    // MARK: - Detail Sections

    private var detailSections: some View {
        VStack(spacing: 16) {
            storeCard

            infoSection(title: "What you could get", icon: "bag.fill") {
                Text(basket.itemsDescription)
                    .font(.body)
                Text(basket.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            infoSection(title: "Pickup time", icon: "clock.fill") {
                Text(Utilities.formatPickupWindow(
                    start: basket.pickupStartTime,
                    end: basket.pickupEndTime
                ))
                .font(.body.weight(.medium))
            }

            locationMapCard

            infoSection(title: "Availability", icon: "number") {
                Text("\(basket.remainingCount) baskets remaining")
                    .font(.body.weight(.medium))
                    .foregroundStyle(basket.remainingCount <= 3 ? .red : .primary)
            }

            priceCard
        }
        .padding(DesignTokens.padding)
    }

    private var storeCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(basket.store.name)
                    .font(.headline)
                Text(basket.store.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.orange)
                Text(String(format: "%.1f", basket.store.rating))
                    .font(.subheadline.bold())
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
    }

    private var priceCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Price")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    Text(Utilities.formatMoneyGel(basket.originalPrice))
                        .font(.title3)
                        .strikethrough()
                        .foregroundStyle(.secondary)
                    Text(Utilities.formatMoneyGel(basket.discountedPrice))
                        .font(.title.bold())
                        .foregroundStyle(DesignTokens.primaryGreen)
                }
            }
            Spacer()
            Text("Save \(basket.savingsPercent)%")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(DesignTokens.primaryGreen, in: Capsule())
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
    }

    // MARK: - Location Map

    private var storeCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: basket.store.latitude, longitude: basket.store.longitude)
    }

    private var locationMapCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Location", systemImage: "mappin.and.ellipse")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Map(initialPosition: .region(MKCoordinateRegion(
                center: storeCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))) {
                Marker(basket.store.name, coordinate: storeCoordinate)
                    .tint(DesignTokens.primaryGreen)
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.smallCornerRadius))
            .allowsHitTesting(false)
            .overlay {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { showFullMap = true }
            }

            if let dist = LocationManager.shared.distanceToStore(basket.store) {
                Label(String(format: "%.1f km away", dist), systemImage: "location.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .fullScreenCover(isPresented: $showFullMap) {
            StoreMapFullView(store: basket.store)
        }
    }

    // MARK: - Order Bar

    private var orderBar: some View {
        Button {
            showCheckout = true
        } label: {
            Text("Order for \(Utilities.formatMoneyGel(basket.discountedPrice))")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    DesignTokens.primaryGreen,
                    in: RoundedRectangle(cornerRadius: DesignTokens.cornerRadius)
                )
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    // MARK: - Reusable Info Section

    private func infoSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
    }
}

#Preview {
    NavigationStack {
        BasketDetailView(basket: MockData.baskets[0])
    }
    .environment(AppState())
}
