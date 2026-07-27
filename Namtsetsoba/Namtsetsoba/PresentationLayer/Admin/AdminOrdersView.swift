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
                    .adminCardRow()
            } else if viewModel.filteredOrders.isEmpty {
                Text("No orders found.")
                    .foregroundStyle(.secondary)
                    .adminCardRow()
            } else {
                ForEach(viewModel.filteredOrders) { order in
                    AdminRowCard {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(order.basket.title).font(.headline)
                                    Text(order.basket.store.name)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                AdminStatusPill(text: order.status.displayName, color: order.status.color)
                            }
                            HStack {
                                Label(Utilities.formatOrderDate(order.orderDate), systemImage: "calendar")
                                Spacer()
                                Text(Utilities.formatMoneyGel(order.totalPaid))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            Text("Code \(order.pickupCode)")
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                        }
                    }
                    .adminCardRow()
                }
            }

            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red).font(.caption).adminCardRow()
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
