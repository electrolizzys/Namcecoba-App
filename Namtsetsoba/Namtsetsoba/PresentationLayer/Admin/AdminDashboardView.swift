import SwiftUI

struct AdminDashboardView: View {
    @Environment(\.mainTabSelection) private var mainTabSelection
    @State private var viewModel = AdminDashboardViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(spacing: 16) {
                Picker("Period", selection: $viewModel.period) {
                    ForEach(SalesPeriod.allCases) { period in
                        Text(period.localizedName).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.period) { _, _ in
                    Task { await viewModel.load() }
                }

                if viewModel.isLoading && viewModel.stats == nil {
                    ProgressView().padding(.top, 60)
                } else if let stats = viewModel.stats {
                    statGrid(stats)
                    moneyCard(stats)
                }

                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(.red).font(.caption)
                }
            }
            .padding(16)
            .padding(.bottom, DesignTokens.floatingTabBarClearance)
        }
        .background(DesignTokens.selectedChipBackground)
        .navigationTitle(L(.tabDashboard))
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private func statGrid(_ stats: AdminDashboardStats) -> some View {
        LazyVGrid(columns: columns, spacing: 12) {
            NavigationLink { AdminSalesView() } label: {
                AdminStatCard(icon: "banknote.fill", title: L(.adminRevenue),
                              value: Utilities.formatMoneyGel(stats.pickedUpRevenue),
                              tint: AdminPalette.green, showsChevron: true)
            }
            .buttonStyle(.plain)

            Button {
                mainTabSelection?.openAdminOrders()
            } label: {
                AdminStatCard(icon: "bag.fill", title: L(.adminPickedUpOrders),
                              value: "\(stats.pickedUpOrderCount)",
                              tint: AdminPalette.blue, showsChevron: true)
            }
            .buttonStyle(.plain)

            Button {
                mainTabSelection?.openAdminOrders()
            } label: {
                AdminStatCard(icon: "xmark.bin.fill", title: L(.adminCancelledOrders),
                              value: "\(stats.cancelledOrderCount)",
                              tint: AdminPalette.red, showsChevron: true)
            }
            .buttonStyle(.plain)

            Button {
                mainTabSelection?.openAdminStores()
            } label: {
                AdminStatCard(icon: "storefront.fill", title: L(.tabStores),
                              value: "\(stats.activeStoreCount)",
                              tint: AdminPalette.orange, showsChevron: true)
            }
            .buttonStyle(.plain)

            NavigationLink { AdminOffersView() } label: {
                AdminStatCard(icon: "leaf.fill", title: L(.adminActiveOffers),
                              value: "\(stats.activeOfferCount)",
                              tint: AdminPalette.green, showsChevron: true)
            }
            .buttonStyle(.plain)

            AdminStatCard(icon: "person.2.fill", title: L(.adminCustomersWithPickup),
                          value: "\(stats.customersWithPickupCount)",
                          tint: AdminPalette.purple)
        }
    }

    private func moneyCard(_ stats: AdminDashboardStats) -> some View {
        AdminSectionCard(title: L(.adminMoneyPickedUp), icon: "chart.pie.fill") {
            AdminMetricRow(title: L(.adminPlatform10), value: Utilities.formatMoneyGel(stats.platformCommission))
            Divider()
            AdminMetricRow(title: L(.adminStoreIncome), value: Utilities.formatMoneyGel(stats.storeIncome))
            Divider()
            AdminMetricRow(title: L(.adminCancelRate), value: String(format: "%.0f%%", stats.cancelRate * 100),
                           tint: stats.cancelRate > 0.2 ? AdminPalette.red : .primary)
        }
    }
}
