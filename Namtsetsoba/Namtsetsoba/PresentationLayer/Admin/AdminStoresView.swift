import SwiftUI

struct AdminStoresView: View {
    @Environment(\.mainTabSelection) private var mainTabSelection
    @State private var viewModel = AdminStoresViewModel()
    @State private var editingStore: Store?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.isLoading && viewModel.stores.isEmpty {
                    ProgressView().padding(.top, 40)
                } else if viewModel.stores.isEmpty {
                    Text(L(.adminNoStores))
                        .foregroundStyle(.secondary)
                        .padding(.top, 40)
                } else {
                    ForEach(viewModel.stores) { store in
                        storeCard(store)
                    }
                }

                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(.red).font(.caption)
                }
            }
            .padding(16)
            .padding(.bottom, DesignTokens.floatingTabBarClearance)
        }
        .background(DesignTokens.selectedChipBackground)
        .navigationTitle(L(.tabStores))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    mainTabSelection?.openAdminAddVenue()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $editingStore) { store in
            NavigationStack {
                AdminStoreFormView(store: store) {
                    Task { await viewModel.load() }
                }
            }
        }
        .task { await viewModel.load() }
        .onAppear { Task { await viewModel.load() } }
        .refreshable { await viewModel.load() }
    }

    private func storeCard(_ store: Store) -> some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink {
                StoreDetailView(store: store)
            } label: {
                AdminRowCard { storeRow(store) }
            }
            .buttonStyle(.plain)

            Button {
                editingStore = store
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DesignTokens.primaryGreen)
                    .frame(width: 32, height: 32)
                    .background(DesignTokens.primaryGreen.opacity(0.12), in: Circle())
            }
            .buttonStyle(.plain)
            .padding(10)
        }
    }

    private func storeRow(_ store: Store) -> some View {
        HStack(spacing: 12) {
            StoreThumbnailView(store: store, size: 52)
                .id("\(store.id.uuidString)-\(store.logoURL ?? "")")

            VStack(alignment: .leading, spacing: 4) {
                Text(store.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(store.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text("\(store.category.icon) \(store.category.rawValue)")
                    Text("·")
                    Text("\(store.openTime)–\(store.closeTime)")
                    Spacer()
                    Label(store.displayRatingText, systemImage: "star.fill")
                        .foregroundStyle(.orange)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            // Leave room for the floating edit button.
            .padding(.trailing, 36)
        }
    }
}
