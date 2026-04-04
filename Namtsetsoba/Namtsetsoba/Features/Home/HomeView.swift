import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("Baskets will appear here")
            }
            .navigationTitle("Offers")
        }
    }
}

#Preview {
    HomeView()
}
