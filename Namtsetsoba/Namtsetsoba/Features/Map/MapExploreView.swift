import SwiftUI
import MapKit

struct MapExploreView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var allStores: [Store] = []
    @State private var selectedStore: Store?
    @State private var showStoreDetail = false
    @State private var isLoading = true

    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.7151, longitude: 44.8271),
        span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
    ))

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $cameraPosition) {
                    UserAnnotation()

                    ForEach(allStores) { store in
                        Annotation(store.name, coordinate: CLLocationCoordinate2D(
                            latitude: store.latitude,
                            longitude: store.longitude
                        )) {
                            Button {
                                selectedStore = store
                                showStoreDetail = true
                            } label: {
                                VStack(spacing: 2) {
                                    ZStack {
                                        Circle()
                                            .fill(DesignTokens.primaryGreen)
                                            .frame(width: 36, height: 36)
                                        Text(store.category.icon)
                                            .font(.system(size: 18))
                                    }
                                    Text(store.name)
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                            }
                        }
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }

                if isLoading {
                    ProgressView()
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark")
                            Text("Close")
                        }
                    }
                }
            }
            .task {
                await loadStores()
            }
            .navigationDestination(isPresented: $showStoreDetail) {
                if let store = selectedStore {
                    StoreDetailView(store: store)
                }
            }
            .onAppear {
                if let userLoc = LocationManager.shared.userLocation {
                    cameraPosition = .region(MKCoordinateRegion(
                        center: userLoc,
                        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                    ))
                }
            }
        }
    }

    private func loadStores() async {
        isLoading = true
        allStores = await StoreService.shared.fetchStores()
        isLoading = false
    }
}

#Preview {
    MapExploreView()
        .environment(AppState())
}
