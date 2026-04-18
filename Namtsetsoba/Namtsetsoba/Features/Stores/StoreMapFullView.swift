import SwiftUI
import MapKit

struct StoreMapFullView: View {
    let store: Store
    @Environment(\.dismiss) private var dismiss

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: store.latitude, longitude: store.longitude)
    }

    var body: some View {
        NavigationStack {
            Map(initialPosition: .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            ))) {
                Marker(store.name, coordinate: coordinate)
                    .tint(DesignTokens.primaryGreen)

                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .navigationTitle(store.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .overlay(alignment: .bottom) {
                VStack(spacing: 4) {
                    Text(store.address)
                        .font(.subheadline.weight(.medium))
                    if let dist = LocationManager.shared.distanceToStore(store) {
                        Text(String(format: "%.1f km away", dist))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
            }
        }
    }
}

#Preview {
    StoreMapFullView(store: MockData.stores[0])
}
