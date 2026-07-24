import SwiftUI

struct AdminOrdersView: View {
    @State private var viewModel = AdminOrdersViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        List {
            Section {
                Picker("Status", selection: $viewModel.statusFilter) {
                    Text("All").tag(OrderStatus?.none)
                    ForEach(OrderStatus.allCases, id: \.self) { status in
                        Text(status.displayName).tag(Optional(status))
                    }
                }
            }

            if viewModel.isLoading && viewModel.orders.isEmpty {
                ProgressView()
            } else if viewModel.filteredOrders.isEmpty {
                Text("No orders found.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.filteredOrders) { order in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(order.basket.title).font(.headline)
                            Spacer()
                            Text(order.status.displayName)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(order.status.color)
                        }
                        Text(order.basket.store.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack {
                            Text(Utilities.formatOrderDate(order.orderDate))
                            Spacer()
                            Text(Utilities.formatMoneyGel(order.totalPaid)).fontWeight(.semibold)
                        }
                        .font(.caption)
                        Text("Code \(order.pickupCode)")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }

            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red).font(.caption)
            }
        }
        .scrollContentBackground(.hidden)
        .lightGreenScreenStyle()
        .navigationTitle("Recent Orders")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}
