import SwiftUI

struct AdminOffersView: View {
    @State private var viewModel = AdminOffersViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.isLoading && viewModel.offers.isEmpty {
                    ProgressView().padding(.top, 40)
                } else if viewModel.offers.isEmpty {
                    Text(L(.adminNoOffers))
                        .foregroundStyle(.secondary)
                        .padding(.top, 40)
                } else {
                    ForEach(viewModel.offers) { basket in
                        NavigationLink {
                            BasketDetailView(basket: basket)
                        } label: {
                            AdminRowCard { offerRow(basket) }
                        }
                        .buttonStyle(.plain)
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
        .navigationTitle(L(.adminActiveOffers))
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private func offerRow(_ basket: Basket) -> some View {
        HStack(spacing: 12) {
            StoreThumbnailView(store: basket.store, size: 52)
                .id("\(basket.store.id.uuidString)-\(basket.store.logoURL ?? "")")

            VStack(alignment: .leading, spacing: 4) {
                Text(basket.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(basket.store.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Text(Utilities.formatMoneyGel(basket.discountedPrice))
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignTokens.primaryGreen)
                    Spacer()
                    AdminStatusPill(
                        text: String(format: L(.adminOffersLeft), basket.remainingCount),
                        color: basket.remainingCount > 0 ? AdminPalette.green : AdminPalette.red
                    )
                }
                .font(.caption)
            }
        }
    }
}
