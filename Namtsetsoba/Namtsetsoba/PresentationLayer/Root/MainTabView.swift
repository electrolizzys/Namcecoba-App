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
                .tag(0)
                .toolbar(.hidden, for: .tabBar)

            StoresListView()
                .tag(1)
                .toolbar(.hidden, for: .tabBar)

            OrdersView()
                .tag(2)
                .toolbar(.hidden, for: .tabBar)

            NotificationsView()
                .tag(3)
                .toolbar(.hidden, for: .tabBar)

            ProfileView()
                .tag(4)
                .toolbar(.hidden, for: .tabBar)
        }
        .tint(DesignTokens.primaryGreen)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            GlassTabBar(
                selectedTab: $mainTabSelection.selectedTab,
                primaryTitle: primaryTabTitle,
                primaryIcon: primaryTabIcon,
                unreadCount: appState.unreadCount
            )
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
        .background(
            DesignTokens.selectedChipBackground
                .ignoresSafeArea()
        )
        .onChange(of: appState.currentRole) { _, role in
            if role == .business && mainTabSelection.selectedTab == 1 {
                mainTabSelection.selectedTab = 0
            }
        }
    }
}

// MARK: - Glass Tab Bar

/// A floating, translucent "liquid glass" tab bar with an animated selection pill.
private struct GlassTabBar: View {
    @Binding var selectedTab: Int
    let primaryTitle: String
    let primaryIcon: String
    let unreadCount: Int

    @Namespace private var pillNamespace

    private struct TabItem: Identifiable {
        let id: Int
        let icon: String
        let title: String
        let color: Color
        var badge: Int = 0
    }

    private var items: [TabItem] {
        [
            TabItem(id: 0, icon: primaryIcon, title: primaryTitle, color: DesignTokens.primaryGreen),
            TabItem(id: 1, icon: "storefront.fill", title: "Stores", color: DesignTokens.accentOrange),
            TabItem(id: 2, icon: "bag.fill", title: "Orders", color: Color(red: 0.23, green: 0.51, blue: 0.96)),
            TabItem(id: 3, icon: "bell.fill", title: "Alerts", color: Color(red: 0.93, green: 0.31, blue: 0.44), badge: unreadCount),
            TabItem(id: 4, icon: "person.fill", title: "Profile", color: Color(red: 0.56, green: 0.4, blue: 0.86)),
        ]
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                tabButton(for: item)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule(style: .continuous)
                .fill(.regularMaterial)
        )
        .overlay(
            Capsule(style: .continuous)
                .strokeBorder(Color.white.opacity(0.5), lineWidth: 0.5)
        )
        .clipShape(Capsule(style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 14, y: 6)
    }

    private func tabButton(for item: TabItem) -> some View {
        let isSelected = selectedTab == item.id
        let iconColor = isSelected ? item.color : item.color.opacity(0.55)
        let labelColor = isSelected ? item.color : Color.secondary

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.74)) {
                selectedTab = item.id
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: item.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(height: 21)
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
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
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
