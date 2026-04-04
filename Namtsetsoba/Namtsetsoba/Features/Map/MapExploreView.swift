import SwiftUI
import MapKit

struct MapExploreView: View {
    var body: some View {
        Map {
            // Add annotations when stores have coordinates
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MapExploreView()
    }
}
