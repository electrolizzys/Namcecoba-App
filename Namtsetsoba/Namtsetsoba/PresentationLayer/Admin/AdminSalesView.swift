import SwiftUI

struct AdminSalesView: View {
    @State private var viewModel = AdminSalesViewModel()

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

                if viewModel.isLoading && viewModel.rows.isEmpty {
                    ProgressView().padding(.top, 40)
                } else if viewModel.rows.isEmpty {
                    Text("No picked-up sales in this period.")
                        .foregroundStyle(.secondary)
                        .padding(.top, 40)
                } else {
                    AdminSectionCard(title: "Totals", icon: "sum") {
                        AdminMetricRow(title: "Orders", value: "\(viewModel.totals.orders)")
                        Divider()
                        AdminMetricRow(title: "Revenue", value: Utilities.formatMoneyGel(viewModel.totals.revenue))
                        Divider()
                        AdminMetricRow(title: "Commission 10%", value: Utilities.formatMoneyGel(viewModel.totals.commission))
                        Divider()
                        AdminMetricRow(title: "Store income", value: Utilities.formatMoneyGel(viewModel.totals.storeIncome))
                    }

                    ForEach(viewModel.rows) { item in
                        AdminRowCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.storeName).font(.headline)
                                Text("\(item.orderCount) orders · \(Utilities.formatMoneyGel(item.totalRevenue)) revenue")
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
        }
        .background(DesignTokens.selectedChipBackground)
        .navigationTitle("Sales by Store")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}
