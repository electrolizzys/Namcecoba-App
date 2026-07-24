import SwiftUI

struct AdminStoresView: View {
    @State private var viewModel = AdminStoresViewModel()
    @State private var showAdd = false

    var body: some View {
        List {
            if viewModel.isLoading && viewModel.stores.isEmpty {
                ProgressView()
            } else if viewModel.stores.isEmpty {
                Text("No stores yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.stores) { store in
                    NavigationLink {
                        AdminStoreFormView(store: store) {
                            Task { await viewModel.load() }
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.name).font(.headline)
                            Text(store.address)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                Text(store.category.rawValue)
                                Text("·")
                                Text("\(store.openTime)–\(store.closeTime)")
                                Spacer()
                                Label(String(format: "%.1f", store.rating), systemImage: "star.fill")
                                    .foregroundStyle(.orange)
                            }
                            .font(.caption)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red).font(.caption)
            }
        }
        .scrollContentBackground(.hidden)
        .lightGreenScreenStyle()
        .navigationTitle("Stores")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                AdminStoreFormView {
                    Task { await viewModel.load() }
                }
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}
