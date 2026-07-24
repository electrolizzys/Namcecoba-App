import SwiftUI

struct AdminDashboardView: View {
    @State private var viewModel = AdminDashboardViewModel()

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

            if viewModel.isLoading && viewModel.stats == nil {
                ProgressView()
            } else if let stats = viewModel.stats {
                Section("Money (picked up only)") {
                    metric("Revenue", Utilities.formatMoneyGel(stats.pickedUpRevenue))
                    metric("Platform (10%)", Utilities.formatMoneyGel(stats.platformCommission))
                    metric("Store income", Utilities.formatMoneyGel(stats.storeIncome))
                }
                Section("Activity") {
                    metric("Picked up orders", "\(stats.pickedUpOrderCount)")
                    metric("Cancelled orders", "\(stats.cancelledOrderCount)")
                    metric("Cancel rate", String(format: "%.0f%%", stats.cancelRate * 100))
                    metric("Customers with pickup", "\(stats.customersWithPickupCount)")
                }
                Section("Catalog") {
                    metric("Stores", "\(stats.activeStoreCount)")
                    metric("Active offers", "\(stats.activeOfferCount)")
                }
            }

            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red).font(.caption)
            }
        }
        .scrollContentBackground(.hidden)
        .lightGreenScreenStyle()
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private func metric(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value).fontWeight(.semibold)
        }
    }
}
