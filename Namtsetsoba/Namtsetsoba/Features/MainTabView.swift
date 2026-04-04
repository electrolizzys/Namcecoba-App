import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Offers", systemImage: "leaf.fill") }

            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            MapExploreView()
                .tabItem { Label("Map", systemImage: "map.fill") }

            OrdersView()
                .tabItem { Label("Orders", systemImage: "bag.fill") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
}

#Preview {
    MainTabView()
}
