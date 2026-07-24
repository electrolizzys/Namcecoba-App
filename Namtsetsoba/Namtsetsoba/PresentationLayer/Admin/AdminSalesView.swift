import SwiftUI

struct AdminSalesView: View {
    @State private var viewModel = AdminSalesViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        List {
            Section {
                Picker("Period", selection: $viewModel.period) {
                    ForEach(SalesPeriod.allCases) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .onChange(of: viewModel.period) { _, _ in
                    Task { await viewModel.load() }
                }
            }

            if viewModel.isLoading && viewModel.rows.isEmpty {
                ProgressView()
            } else if viewModel.rows.isEmpty {
                Text("No picked-up sales in this period.")
                    .foregroundStyle(.secondary)
            } else {
                Section("Totals") {
                    row("Orders", "\(viewModel.totals.orders)")
                    row("Revenue", Utilities.formatMoneyGel(viewModel.totals.revenue))
                    row("Commission 10%", Utilities.formatMoneyGel(viewModel.totals.commission))
                    row("Store income", Utilities.formatMoneyGel(viewModel.totals.storeIncome))
                }

                Section("By store") {
                    ForEach(viewModel.rows) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.storeName).font(.headline)
                            Text("\(item.orderCount) orders · \(Utilities.formatMoneyGel(item.totalRevenue)) revenue")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Text("Commission \(Utilities.formatMoneyGel(item.platformCommission))")
                                Spacer()
                                Text("Store \(Utilities.formatMoneyGel(item.storeIncome))")
                            }
                            .font(.caption.weight(.medium))
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red).font(.caption)
            }
        }
        .scrollContentBackground(.hidden)
        .lightGreenScreenStyle()
        .navigationTitle("Sales by Store")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).fontWeight(.semibold)
        }
    }
}
