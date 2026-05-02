import SwiftUI

@Observable
final class MainTabSelection {
    var selectedTab: Int = 0

    func openOrders(isBusiness: Bool) {
        selectedTab = isBusiness ? 1 : 2
    }

    func openMyProductsTab() {
        selectedTab = 0
    }
}

private struct MainTabSelectionKey: EnvironmentKey {
    static let defaultValue: MainTabSelection? = nil
}

extension EnvironmentValues {
    var mainTabSelection: MainTabSelection? {
        get { self[MainTabSelectionKey.self] }
        set { self[MainTabSelectionKey.self] = newValue }
    }
}

struct MainTabView: View {
    @Bindable var mainTabSelection: MainTabSelection
    @Environment(AppState.self) private var appState

    var body: some View {
        TabView(selection: $mainTabSelection.selectedTab) {
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
            .tag(0)

            if appState.currentRole != .business {
                StoresListView()
                    .tabItem { Label("Stores", systemImage: "storefront.fill") }
                    .tag(1)
            }

            OrdersView()
                .tabItem { Label("Orders", systemImage: "bag.fill") }
                .tag(appState.currentRole == .business ? 1 : 2)

            NotificationsView()
                .tabItem { Label("Notifications", systemImage: "bell.fill") }
                .badge(appState.unreadCount)
                .tag(appState.currentRole == .business ? 2 : 3)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(appState.currentRole == .business ? 3 : 4)
        }
        .tint(DesignTokens.primaryGreen)
        .onChange(of: appState.currentRole) { _, _ in
            mainTabSelection.selectedTab = 0
        }
    }
}

private struct MainTabViewPreviewHost: View {
    @State private var tabSelection = MainTabSelection()

    var body: some View {
        MainTabView(mainTabSelection: tabSelection)
            .environment(AppState())
            .environment(\.mainTabSelection, tabSelection)
    }
}

#Preview {
    MainTabViewPreviewHost()
}
