import SwiftUI

struct AdminUsersView: View {
    @State private var viewModel = AdminUsersViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        List {
            if viewModel.isLoading && viewModel.users.isEmpty {
                ProgressView()
            } else if viewModel.filteredUsers.isEmpty {
                Text("No users found.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.filteredUsers, id: \.id) { user in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(user.username.isEmpty ? "—" : user.username)
                                .font(.headline)
                            Spacer()
                            Text(user.role.displayName)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(DesignTokens.primaryGreen)
                        }
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(user.id.uuidString)
                            .font(.caption2.monospaced())
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 2)
                }
            }

            if let error = viewModel.errorMessage {
                Text(error).foregroundStyle(.red).font(.caption)
            }
        }
        .scrollContentBackground(.hidden)
        .lightGreenScreenStyle()
        .navigationTitle("Users")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, prompt: "Search name, email, or id")
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}
