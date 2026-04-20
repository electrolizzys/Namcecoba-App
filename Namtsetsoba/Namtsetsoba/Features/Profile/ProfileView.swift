import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showEditProfile = false

    var body: some View {
        @Bindable var state = appState

        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: appState.currentRole == .business
                              ? "storefront.circle.fill"
                              : "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(DesignTokens.primaryGreen)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(appState.username.isEmpty ? "My Account" : appState.username)
                                .font(.headline)
                            Text(appState.userEmail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button { showEditProfile = true } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundStyle(DesignTokens.primaryGreen)
                        }
                    }
                }

                Section("Activity") {
                    if appState.currentRole == .business {
                        Label(
                            "\(appState.businessBaskets.count) active baskets",
                            systemImage: "storefront.fill"
                        )
                    } else {
                        Label(
                            "\(appState.orders.count) orders placed",
                            systemImage: "bag.fill"
                        )
                        Label(
                            "\(appState.frequentStoreIds.count) favorite stores",
                            systemImage: "heart.fill"
                        )
                    }
                }

                Section("Support") {
                    Label("Help Center", systemImage: "questionmark.circle")
                    Label("About Namtsetsoba", systemImage: "info.circle")
                }

                Section {
                    Button(role: .destructive) {
                        authViewModel.signOut()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .refreshable {
                await appState.loadUserInfo()
                await appState.loadOrders()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
        }
    }
}

// MARK: - Edit Profile

struct EditProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var newUsername = ""
    @State private var isSaving = false
    @State private var message: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Username") {
                    TextField("Username", text: $newUsername)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                Section("Email") {
                    Text(appState.userEmail)
                        .foregroundStyle(.secondary)
                }

                if let message {
                    Section {
                        Text(message)
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveUsername() }
                        .bold()
                        .disabled(newUsername.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
            .onAppear { newUsername = appState.username }
        }
    }

    private func saveUsername() {
        let trimmed = newUsername.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        isSaving = true
        Task { @MainActor in
            do {
                try await supabase.auth.update(user: .init(data: ["username": .string(trimmed)]))
                appState.username = trimmed
                message = "Username updated!"
                try? await Task.sleep(for: .seconds(1))
                dismiss()
            } catch {
                message = "Failed to update: \(error.localizedDescription)"
            }
            isSaving = false
        }
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
        .environment(AuthViewModel())
}

#Preview("Edit Profile") {
    EditProfileView()
        .environment(AppState())
}
