import SwiftUI

struct AdminAnalyticsView: View {
    @State private var viewModel = AdminAnalyticsViewModel()

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

            if viewModel.isLoading && viewModel.snapshot == nil {
                ProgressView()
            } else if let snapshot = viewModel.snapshot {
                Section("Order status breakdown") {
                    ForEach(OrderStatus.allCases, id: \.self) { status in
                        HStack {
                            Text(status.displayName)
                            Spacer()
                            Text("\(snapshot.statusCounts[status] ?? 0)")
                                .fontWeight(.semibold)
                        }
                    }
                }

                Section("Key rates") {
                    HStack {
                        Text("Cancel rate")
                        Spacer()
                        Text(String(format: "%.0f%%", snapshot.cancelRate * 100))
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Repeat customers")
                        Spacer()
                        Text(String(format: "%.0f%%", snapshot.repeatCustomerRate * 100))
                            .fontWeight(.semibold)
                    }
                    Text("Share of customers with 2+ picked-up orders in this period.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Average order value") {
                    HStack {
                        Text("AOV (picked up)")
                        Spacer()
                        Text(Utilities.formatMoneyGel(snapshot.averageOrderValue))
                            .fontWeight(.semibold)
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red).font(.caption)
            }
        }
        .scrollContentBackground(.hidden)
        .lightGreenScreenStyle()
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}
