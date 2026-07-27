import SwiftUI

struct AdminUsersView: View {
    @State private var viewModel = AdminUsersViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        List {
            if viewModel.isLoading && viewModel.users.isEmpty {
                ProgressView()
                    .adminCardRow()
            } else if viewModel.filteredUsers.isEmpty {
                Text("No users found.")
                    .foregroundStyle(.secondary)
                    .adminCardRow()
            } else {
                ForEach(viewModel.filteredUsers, id: \.id) { user in
                    AdminRowCard {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle().fill(roleColor(user.role).opacity(0.15))
                                Image(systemName: roleIcon(user.role))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(roleColor(user.role))
                            }
                            .frame(width: 42, height: 42)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(user.username.isEmpty ? "—" : user.username)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer(minLength: 8)
                            AdminStatusPill(text: user.role.displayName, color: roleColor(user.role))
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
        .navigationTitle("Users")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, prompt: "Search name, email, or id")
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private func roleColor(_ role: UserRole) -> Color {
        switch role {
        case .admin: AdminPalette.purple
        case .business: AdminPalette.orange
        case .customer: AdminPalette.blue
        }
    }

    private func roleIcon(_ role: UserRole) -> String {
        switch role {
        case .admin: "shield.lefthalf.filled"
        case .business: "storefront.fill"
        case .customer: "person.fill"
        }
    }
}
