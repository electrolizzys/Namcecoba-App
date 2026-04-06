import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        AuthView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: appState.currentRole == .business
                                  ? "storefront.circle.fill"
                                  : "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(DesignTokens.primaryGreen)
                            VStack(alignment: .leading) {
                                Text(appState.currentRole == .business
                                     ? appState.businessStore.name
                                     : "Sign In")
                                    .font(.headline)
                                Text(appState.currentRole == .business
                                     ? appState.businessStore.address
                                     : "Access your account")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
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

                Section("Demo Controls") {
                    Picker("Role", selection: $state.currentRole) {
                        Text("Customer").tag(UserRole.customer)
                        Text("Business").tag(UserRole.business)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Support") {
                    Label("Help Center", systemImage: "questionmark.circle")
                    Label("About Namtsetsoba", systemImage: "info.circle")
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
}
