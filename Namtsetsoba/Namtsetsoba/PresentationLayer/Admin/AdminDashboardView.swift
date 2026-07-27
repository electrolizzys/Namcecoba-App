import SwiftUI

struct AdminDashboardView: View {
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
                        Text(period.displayName).tag(period)
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
                AdminStatCard(icon: "banknote.fill", title: "Revenue",
                              value: Utilities.formatMoneyGel(stats.pickedUpRevenue),
                              tint: AdminPalette.green, showsChevron: true)
            }
            .buttonStyle(.plain)

            NavigationLink { AdminOrdersView() } label: {
                AdminStatCard(icon: "bag.fill", title: "Picked up orders",
                              value: "\(stats.pickedUpOrderCount)",
                              tint: AdminPalette.blue, showsChevron: true)
            }
            .buttonStyle(.plain)

            NavigationLink { AdminOrdersView() } label: {
                AdminStatCard(icon: "xmark.bin.fill", title: "Cancelled orders",
                              value: "\(stats.cancelledOrderCount)",
                              tint: AdminPalette.red, showsChevron: true)
            }
            .buttonStyle(.plain)

            NavigationLink { AdminStoresView() } label: {
                AdminStatCard(icon: "storefront.fill", title: "Stores",
                              value: "\(stats.activeStoreCount)",
                              tint: AdminPalette.orange, showsChevron: true)
            }
            .buttonStyle(.plain)

            NavigationLink { AdminOffersView() } label: {
                AdminStatCard(icon: "leaf.fill", title: "Active offers",
                              value: "\(stats.activeOfferCount)",
                              tint: AdminPalette.green, showsChevron: true)
            }
            .buttonStyle(.plain)

            AdminStatCard(icon: "person.2.fill", title: "Customers with pickup",
                          value: "\(stats.customersWithPickupCount)",
                          tint: AdminPalette.purple)
        }
    }

    private func moneyCard(_ stats: AdminDashboardStats) -> some View {
        AdminSectionCard(title: "Money (picked up only)", icon: "chart.pie.fill") {
            AdminMetricRow(title: "Platform (10%)", value: Utilities.formatMoneyGel(stats.platformCommission))
            Divider()
            AdminMetricRow(title: "Store income", value: Utilities.formatMoneyGel(stats.storeIncome))
            Divider()
            AdminMetricRow(title: "Cancel rate", value: String(format: "%.0f%%", stats.cancelRate * 100),
                           tint: stats.cancelRate > 0.2 ? AdminPalette.red : .primary)
        }
    }
}
