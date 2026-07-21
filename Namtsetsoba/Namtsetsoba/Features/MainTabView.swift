import SwiftUI

@Observable
final class MainTabSelection {
    var selectedTab: Int = 0

    func openOrders(isBusiness: Bool) {
        selectedTab = 2
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

/// Stable root for tab 0 — avoids swapping `HomeView`/`BusinessHomeView` inside `TabView` after profile load.
struct PrimaryOfferTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if !appState.isProfileReady {
                ZStack {
                    DesignTokens.selectedChipBackground
                        .ignoresSafeArea()
                    ProgressView()
                }
            } else if appState.currentRole == .business {
                BusinessHomeView()
            } else {
                HomeView()
            }
        }
    }
}

struct MainTabView: View {
    @Bindable var mainTabSelection: MainTabSelection
    @Environment(AppState.self) private var appState

    private var primaryTabTitle: String {
        guard appState.isProfileReady else { return "Home" }
        return appState.currentRole == .business ? "My Products" : "Offers"
    }

    private var primaryTabIcon: String {
        guard appState.isProfileReady else { return "house.fill" }
        return appState.currentRole == .business ? "storefront.fill" : "leaf.fill"
    }

    var body: some View {
        TabView(selection: $mainTabSelection.selectedTab) {
            PrimaryOfferTabView()
                .tabItem {
                    Label(primaryTabTitle, systemImage: primaryTabIcon)
                }
                .tag(0)

            StoresListView()
                .tabItem { Label("Stores", systemImage: "storefront.fill") }
                .tag(1)

            OrdersView()
                .tabItem { Label("Orders", systemImage: "bag.fill") }
                .tag(2)

            NotificationsView()
                .tabItem { Label("Notifications", systemImage: "bell.fill") }
                .badge(appState.unreadCount)
                .tag(3)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(4)
        }
        .tint(DesignTokens.primaryGreen)
        .appTabBarStyle()
        .onChange(of: appState.currentRole) { _, role in
            if role == .business && mainTabSelection.selectedTab == 1 {
                mainTabSelection.selectedTab = 0
            }
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
