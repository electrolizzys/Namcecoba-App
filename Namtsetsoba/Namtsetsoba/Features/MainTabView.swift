import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        TabView {
            Group {
                if appState.currentRole == .business {
                    BusinessHomeView()
                } else {
                    HomeView()
                }
            }
            .tabItem {
                Label(
                    appState.currentRole == .business ? "My Products" : "Offers",
                    systemImage: appState.currentRole == .business ? "storefront.fill" : "leaf.fill"
                )
            }

            if appState.currentRole != .business {
                StoresListView()
                    .tabItem { Label("Stores", systemImage: "storefront.fill") }
            }

            OrdersView()
                .tabItem { Label("Orders", systemImage: "bag.fill") }

            NotificationsTab()
                .tabItem { Label("Notifications", systemImage: "bell.fill") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(DesignTokens.primaryGreen)
    }
}


private struct NotificationsTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "bell.slash")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("No notifications yet")
                    .font(.headline)
                Text("You'll see updates about your orders here")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
            .navigationTitle("Notifications")
        }
    }
}

private struct ChatTab: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "message")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text("No messages yet")
                    .font(.headline)
                Text("Chat with stores after placing an order")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding()
            .navigationTitle("Chat")
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
