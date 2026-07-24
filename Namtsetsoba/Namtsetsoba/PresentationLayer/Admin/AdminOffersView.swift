import SwiftUI

struct AdminOffersView: View {
    @State private var viewModel = AdminOffersViewModel()

    var body: some View {
        List {
            if viewModel.isLoading && viewModel.offers.isEmpty {
                ProgressView()
            } else if viewModel.offers.isEmpty {
                Text("No active offers.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.offers) { basket in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(basket.title).font(.headline)
                        Text(basket.store.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        HStack {
                            Text(Utilities.formatMoneyGel(basket.discountedPrice))
                                .fontWeight(.semibold)
                                .foregroundStyle(DesignTokens.primaryGreen)
                            Spacer()
                            Text("\(basket.remainingCount) left")
                                .font(.caption)
                            Text(Utilities.formatPickupWindow(
                                start: basket.pickupStartTime,
                                end: basket.pickupEndTime
                            ))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
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
        .navigationTitle("Active Offers")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}
