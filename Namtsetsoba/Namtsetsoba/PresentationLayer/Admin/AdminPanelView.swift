import SwiftUI

/// Entry hub for admin tools (opened from Profile when `currentRole == .admin`).
/// Destinations that already have their own tab switch to that tab so the tab bar
/// stays in sync; the rest push onto the profile navigation stack.
struct AdminPanelView: View {
    @Environment(\.mainTabSelection) private var mainTabSelection

    var body: some View {
        List {
            Section(L(.adminOverview)) {
                Button {
                    mainTabSelection?.openAdminDashboard()
                } label: {
                    Label(L(.tabDashboard), systemImage: "chart.bar.fill")
                }

                NavigationLink {
                    AdminAnalyticsView()
                } label: {
                    Label(L(.adminStatistics), systemImage: "chart.xyaxis.line")
                }
            }

            Section(L(.adminCommerce)) {
                NavigationLink {
                    AdminSalesView()
                } label: {
                    Label(L(.adminSalesByStore), systemImage: "banknote")
                }
                NavigationLink {
                    AdminOrdersView()
                } label: {
                    Label(L(.adminRecentOrders), systemImage: "bag.fill")
                }
                NavigationLink {
                    AdminOffersView()
                } label: {
                    Label(L(.adminActiveOffers), systemImage: "leaf.fill")
                }
            }

            Section(L(.adminDirectory)) {
                Button {
                    mainTabSelection?.openAdminStores()
                } label: {
                    Label(L(.tabStores), systemImage: "storefront.fill")
                }
                NavigationLink {
                    AdminUsersView()
                } label: {
                    Label(L(.adminUsers), systemImage: "person.3.fill")
                }
            }

            FloatingTabBarListFiller.section
        }
        .scrollContentBackground(.hidden)
        .lightGreenScreenStyle()
        .navigationTitle(L(.adminPanelTitle))
        .navigationBarTitleDisplayMode(.inline)
    }
}
