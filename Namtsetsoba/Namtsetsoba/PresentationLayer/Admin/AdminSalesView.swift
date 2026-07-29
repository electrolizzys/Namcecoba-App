import SwiftUI

struct AdminSalesView: View {
    @State private var viewModel = AdminSalesViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(spacing: 16) {
                AdminPeriodPicker(selection: $viewModel.period)
                .onChange(of: viewModel.period) { _, _ in
                    Task { await viewModel.load() }
                }

                if viewModel.isLoading && viewModel.rows.isEmpty {
                    ProgressView().padding(.top, 40)
                } else if viewModel.rows.isEmpty {
                    Text(L(.adminNoSales))
                        .foregroundStyle(.secondary)
                        .padding(.top, 40)
                } else {
                    AdminSectionCard(title: L(.adminTotals), icon: "sum") {
                        AdminMetricRow(title: L(.venueOrders), value: "\(viewModel.totals.orders)")
                        Divider()
                        AdminMetricRow(title: L(.adminRevenue), value: Utilities.formatMoneyGel(viewModel.totals.revenue))
                        Divider()
                        AdminMetricRow(title: L(.adminCommission10), value: Utilities.formatMoneyGel(viewModel.totals.commission))
                        Divider()
                        AdminMetricRow(title: L(.adminStoreIncome), value: Utilities.formatMoneyGel(viewModel.totals.storeIncome))
                    }

                    ForEach(viewModel.rows) { item in
                        AdminRowCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.storeName).font(.headline)
                                Text("\(item.orderCount) \(L(.venueOrders).lowercased()) · \(Utilities.formatMoneyGel(item.totalRevenue)) \(L(.adminRevenue).lowercased())")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                HStack {
                                    Label(Utilities.formatMoneyGel(item.platformCommission), systemImage: "building.columns.fill")
                                    Spacer()
                                    Label(Utilities.formatMoneyGel(item.storeIncome), systemImage: "storefront.fill")
                                }
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(.red).font(.caption)
                }
            }
            .padding(16)
            .floatingTabBarScrollFiller()
        }
        .background(DesignTokens.selectedChipBackground)
        .navigationTitle(L(.adminSalesByStore))
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}
