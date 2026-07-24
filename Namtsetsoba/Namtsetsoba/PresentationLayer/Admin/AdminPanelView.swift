import SwiftUI

/// Entry hub for admin tools (opened from Profile when `currentRole == .admin`).
struct AdminPanelView: View {
    var body: some View {
        List {
            Section("Overview") {
                NavigationLink {
                    AdminDashboardView()
                } label: {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                NavigationLink {
                    AdminAnalyticsView()
                } label: {
                    Label("Statistics", systemImage: "chart.xyaxis.line")
                }
            }

            Section("Commerce") {
                NavigationLink {
                    AdminSalesView()
                } label: {
                    Label("Sales by Store", systemImage: "banknote")
                }
                NavigationLink {
                    AdminOrdersView()
                } label: {
                    Label("Recent Orders", systemImage: "bag.fill")
                }
                NavigationLink {
                    AdminOffersView()
                } label: {
                    Label("Active Offers", systemImage: "leaf.fill")
                }
            }

            Section("Directory") {
                NavigationLink {
                    AdminStoresView()
                } label: {
                    Label("Stores", systemImage: "storefront.fill")
                }
                NavigationLink {
                    AdminUsersView()
                } label: {
                    Label("Users", systemImage: "person.3.fill")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .lightGreenScreenStyle()
        .navigationTitle("Admin Panel")
        .navigationBarTitleDisplayMode(.inline)
    }
}
