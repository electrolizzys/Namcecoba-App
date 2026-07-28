import SwiftUI

@Observable
final class MainTabSelection {
    var selectedTab: Int = 0

    /// Orders live at a different index per role (customers: 3rd tab, venues: 2nd tab).
    func openOrders(isBusiness: Bool) {
        selectedTab = isBusiness ? 1 : 2
    }

    func openMyProductsTab() {
        selectedTab = 0
    }

    // Admin tabs: Dashboard(0), Stores(1), Add Venue(2), Profile(3)
    func openAdminDashboard() { selectedTab = 0 }
    func openAdminStores() { selectedTab = 1 }
    func openAdminAddVenue() { selectedTab = 2 }
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

// MARK: - Tab model

/// The distinct destinations a tab can point to. The visible set is chosen by role.
private enum TabKind: Hashable {
    case customerHome
    case businessProducts
    case customerStores
    case orders
    case alerts
    case profile
    case venueAnalytics
    case adminDashboard
    case adminStores
    case adminAddVenue
}

private struct AppTab: Identifiable {
    let id: Int
    let kind: TabKind
    let title: String
    let icon: String
    let color: Color
    var badge: Int = 0
}

struct MainTabView: View {
    @Bindable var mainTabSelection: MainTabSelection
    @Environment(AppState.self) private var appState

    private static let ordersColor = Color(red: 0.23, green: 0.51, blue: 0.96)
    private static let alertsColor = Color(red: 0.93, green: 0.31, blue: 0.44)
    private static let profileColor = Color(red: 0.56, green: 0.4, blue: 0.86)
    private static let analyticsColor = Color(red: 0.16, green: 0.62, blue: 0.63)

    private var tabKinds: [TabKind] {
        switch appState.currentRole {
        case .business:
            [.businessProducts, .orders, .venueAnalytics, .alerts, .profile]
        case .admin:
            [.adminDashboard, .adminStores, .adminAddVenue, .profile]
        default:
            [.customerHome, .customerStores, .orders, .alerts, .profile]
        }
    }

    private var tabs: [AppTab] {
        tabKinds.enumerated().map { index, kind in
            AppTab(
                id: index,
                kind: kind,
                title: title(for: kind),
                icon: icon(for: kind),
                color: color(for: kind),
                badge: kind == .alerts ? appState.unreadCount : 0
            )
        }
    }

    var body: some View {
        Group {
            if !appState.isProfileReady {
                loadingScreen
            } else {
                tabScaffold
            }
        }
    }

    private var loadingScreen: some View {
        ZStack {
            DesignTokens.selectedChipBackground
                .ignoresSafeArea()
            ProgressView()
        }
    }

    private var tabScaffold: some View {
        // Overlay the custom tab bar. Screens append trailing blank scroll length
        // (FloatingTabBarScrollFiller) so last rows clear the bar without shrinking the viewport.
        ZStack(alignment: .bottom) {
            TabView(selection: $mainTabSelection.selectedTab) {
                ForEach(tabs) { tab in
                    destination(for: tab.kind)
                        .tag(tab.id)
                        .toolbar(.hidden, for: .tabBar)
                }
            }
            .tint(DesignTokens.primaryGreen)

            GlassTabBar(tabs: tabs, selectedTab: $mainTabSelection.selectedTab)
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 10)
        }
        .background(
            DesignTokens.selectedChipBackground
                .ignoresSafeArea()
        )
        .onChange(of: appState.currentRole) { _, _ in
            // Tab meaning changes per role, so land on the first tab to avoid confusion.
            mainTabSelection.selectedTab = 0
        }
    }

    // MARK: - Destinations

    @ViewBuilder
    private func destination(for kind: TabKind) -> some View {
        switch kind {
        case .customerHome:
            HomeView()
        case .businessProducts:
            BusinessHomeView()
        case .customerStores:
            StoresListView()
        case .orders:
            OrdersView()
        case .alerts:
            NotificationsView()
        case .profile:
            ProfileView()
        case .venueAnalytics:
            NavigationStack { VenueAnalyticsView() }
        case .adminDashboard:
            NavigationStack { AdminDashboardView() }
        case .adminStores:
            NavigationStack { AdminStoresView() }
        case .adminAddVenue:
            NavigationStack { AdminAddVenueView() }
        }
    }

    // MARK: - Tab metadata

    private func title(for kind: TabKind) -> String {
        switch kind {
        case .customerHome: L(.tabOffers)
        case .businessProducts: L(.tabMyProducts)
        case .customerStores, .adminStores: L(.tabStores)
        case .orders: L(.tabOrders)
        case .alerts: L(.tabAlerts)
        case .profile: L(.tabProfile)
        case .venueAnalytics: L(.tabAnalytics)
        case .adminDashboard: L(.tabDashboard)
        case .adminAddVenue: L(.tabAddVenue)
        }
    }

    private func icon(for kind: TabKind) -> String {
        switch kind {
        case .customerHome: "leaf.fill"
        case .businessProducts, .customerStores, .adminStores: "storefront.fill"
        case .orders: "bag.fill"
        case .alerts: "bell.fill"
        case .profile: "person.fill"
        case .venueAnalytics: "chart.bar.fill"
        case .adminDashboard: "square.grid.2x2.fill"
        case .adminAddVenue: "plus.circle.fill"
        }
    }

    private func color(for kind: TabKind) -> Color {
        switch kind {
        case .customerHome, .businessProducts, .adminAddVenue: DesignTokens.primaryGreen
        case .customerStores, .adminStores: DesignTokens.accentOrange
        case .orders: Self.ordersColor
        case .alerts: Self.alertsColor
        case .profile: Self.profileColor
        case .venueAnalytics, .adminDashboard: Self.analyticsColor
        }
    }
}

// MARK: - Glass Tab Bar

/// A floating, translucent "liquid glass" tab bar with an animated selection pill.
private struct GlassTabBar: View {
    let tabs: [AppTab]
    @Binding var selectedTab: Int

    @Namespace private var pillNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { item in
                tabButton(for: item)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background {
            ZStack {
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                // Top-down sheen for a glassy, "liquid" highlight.
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.38), Color.white.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .blendMode(.plusLighter)
            }
        }
        .overlay {
            Capsule(style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.75), Color.white.opacity(0.12)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.8
                )
        }
        .clipShape(Capsule(style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 20, y: 9)
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

    private func tabButton(for item: AppTab) -> some View {
        let isSelected = selectedTab == item.id
        let iconColor = isSelected ? item.color : item.color.opacity(0.55)
        let labelColor = isSelected ? item.color : Color.secondary

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.74)) {
                selectedTab = item.id
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: item.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(height: 23)
                    .scaleEffect(isSelected ? 1.06 : 1)
                    .overlay(alignment: .topTrailing) {
                        if item.badge > 0 {
                            Text(item.badge > 99 ? "99+" : "\(item.badge)")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Capsule().fill(Color.red))
                                .offset(x: 12, y: -7)
                        }
                    }

                Text(item.title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(labelColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .background {
                if isSelected {
                    Capsule(style: .continuous)
                        .fill(item.color.opacity(0.15))
                        .matchedGeometryEffect(id: "selectionPill", in: pillNamespace)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
