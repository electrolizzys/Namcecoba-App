import PhotosUI
import SwiftUI
import UIKit

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.mainTabSelection) private var mainTabSelection
    @State private var showEditProfile = false
    @State private var logoPickerItem: PhotosPickerItem?
    @State private var logoUploading = false
    @State private var logoMessage: String?
    @State private var logoMessageIsError = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        profileHeaderAvatar
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
                        Button {
                            mainTabSelection?.openMyProductsTab()
                        } label: {
                            Label(
                                "\(appState.businessBaskets.count) active baskets",
                                systemImage: "storefront.fill"
                            )
                        }

                        Button {
                            mainTabSelection?.openOrders(isBusiness: true)
                        } label: {
                            Label("Incoming orders", systemImage: "bag.fill")
                        }
                    } else {
                        Button {
                            mainTabSelection?.openOrders(isBusiness: false)
                        } label: {
                            Label("\(appState.orders.count) orders placed", systemImage: "bag.fill")
                        }

                        NavigationLink {
                            FavouriteStoresView()
                        } label: {
                            Label("\(appState.frequentStoreIds.count) favorite stores", systemImage: "heart.fill")
                        }
                    }
                }

                if appState.currentRole == .business {
                    Section("Store appearance") {
                        HStack(spacing: 14) {
                            StoreThumbnailView(store: appState.businessStore, size: 72)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Customers see this on Stores and offers.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                PhotosPicker(selection: $logoPickerItem, matching: .images) {
                                    Label(
                                        logoUploading ? "Uploading…" : "Choose store photo",
                                        systemImage: "photo.on.rectangle.angled"
                                    )
                                }
                                .disabled(logoUploading)
                            }
                        }

                        if let logoMessage {
                            Text(logoMessage)
                                .font(.caption)
                                .foregroundStyle(logoMessageIsError ? .red : .green)
                        }
                    }
                    .onChange(of: logoPickerItem) { _, item in
                        guard let item else { return }
                        Task { await uploadStoreLogo(from: item) }
                    }
                }

                Section("Support") {
                    NavigationLink {
                        HelpCenterView()
                    } label: {
                        Label("Help Center", systemImage: "questionmark.circle")
                    }
                    NavigationLink {
                        AboutNamtsetsobaView()
                    } label: {
                        Label("About Namtsetsoba", systemImage: "info.circle")
                    }
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

    private var profileHeaderAvatar: some View {
        let avatarSize: CGFloat = 44
        return Group {
            if appState.currentRole == .business,
               let urlStr = appState.businessStore.logoURL,
               let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "storefront.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(DesignTokens.primaryGreen)
                    default:
                        ProgressView()
                            .frame(width: avatarSize, height: avatarSize)
                    }
                }
                .frame(width: avatarSize, height: avatarSize)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color(.separator).opacity(0.35), lineWidth: 1))
                .id(urlStr)
            } else if appState.currentRole == .business {
                Image(systemName: "storefront.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(DesignTokens.primaryGreen)
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(DesignTokens.primaryGreen)
            }
        }
    }

    @MainActor
    private func uploadStoreLogo(from item: PhotosPickerItem) async {
        logoUploading = true
        logoMessage = nil
        defer { logoUploading = false }

        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data),
              let jpeg = uiImage.jpegData(compressionQuality: 0.85) else {
            logoMessage = "Could not read that image."
            logoMessageIsError = true
            logoPickerItem = nil
            return
        }

        do {
            _ = try await StoreService.shared.uploadStoreLogo(storeId: appState.businessStore.id, jpegData: jpeg)
            if let refreshed = await StoreService.shared.fetchStore(id: appState.businessStore.id) {
                appState.businessStore = refreshed
                appState.businessBaskets = await BasketService.shared.fetchBusinessBaskets(storeId: refreshed.id)
            }
            logoMessage = "Store photo updated."
            logoMessageIsError = false
        } catch {
            logoMessage = error.localizedDescription
            logoMessageIsError = true
        }

        logoPickerItem = nil
    }
}

// MARK: - Favourite stores

struct FavouriteStoresView: View {
    @Environment(AppState.self) private var appState
    @State private var allStores: [Store] = []
    @State private var didAttemptLoad = false

    private var favouriteStores: [Store] {
        allStores
            .filter { appState.frequentStoreIds.contains($0.id) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        Group {
            if !didAttemptLoad {
                ProgressView()
            } else if favouriteStores.isEmpty {
                ContentUnavailableView(
                    "No favourite stores",
                    systemImage: "heart.slash",
                    description: Text("Open the Stores tab, pick a venue, and use Add to Favourites.")
                )
            } else {
                List(favouriteStores) { store in
                    HStack(spacing: 12) {
                        StoreThumbnailView(store: store, size: 48)
                            .id("\(store.id.uuidString)-\(store.logoURL ?? "")")

                        VStack(alignment: .leading, spacing: 2) {
                            Text(store.name)
                                .font(.headline)
                            Text(store.address)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        Spacer(minLength: 8)

                        Button {
                            appState.toggleFavourite(store.id)
                        } label: {
                            Image(systemName: "heart.fill")
                                .font(.title3)
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("Remove from favourites")
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favourite stores")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let fetched = await StoreService.shared.fetchStores()
            await MainActor.run {
                allStores = fetched
                didAttemptLoad = true
            }
        }
        .refreshable {
            let fetched = await StoreService.shared.fetchStores()
            await MainActor.run { allStores = fetched }
        }
    }
}

// MARK: - About

struct AboutNamtsetsobaView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Namtsetsoba connects people in Tbilisi with cafés, bakeries, restaurants, and groceries that list surprise baskets at reduced prices—so good food is rescued instead of wasted.")
                    .font(.body)

                Text("How it works")
                    .font(.headline)

                Text("Venues publish baskets with pickup windows in their neighbourhood. You browse offers, reserve what you like, pay in the app, and collect your bag in person—often the same day.")

                Text("Where we operate")
                    .font(.headline)

                Text("Listings and pickups are intended for Tbilisi, Georgia. Partner venues set their own addresses and hours; distances shown in the app are based on your location.")

                Text("Why it matters")
                    .font(.headline)

                Text("Too much edible food never reaches a plate. Namtsetsoba gives businesses a simple channel to recover value on surplus portions while you discover local spots at friendlier prices.")

                Text("Version")
                    .font(.headline)

                Text("This build is part of an ongoing university/community project. Features and venue coverage will keep expanding.")

                Text("Thank you for choosing smarter leftovers—for your wallet, our city, and the planet.")
                    .foregroundStyle(.secondary)
            }
            .padding(DesignTokens.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("About Namtsetsoba")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Help

struct HelpCenterView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Help Center")
                    .font(.title2.bold())

                if appState.currentRole == .business {
                    venueSections
                } else {
                    customerSections
                }

                Text("Need more help?")
                    .font(.headline)
                Text(appState.currentRole == .business
                     ? "For payouts or account access, contact your project administrator. For customer disputes about pickup, coordinate with the buyer using order details."
                     : "Contact your venue directly for timing questions. For app issues, reach out through your course team or project maintainer.")
                    .foregroundStyle(.secondary)
            }
            .padding(DesignTokens.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Help Center")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var venueSections: some View {
        Text("Your venue account")
            .font(.headline)
        Text("Use My Products to publish baskets with pickup windows and stock. Customers see updates as soon as you publish or edit—ask them to pull to refresh on Offers.")

        Text("Editing baskets")
            .font(.headline)
        Text("Tap ••• on an active basket to Edit text, prices, pickup times, or reduce how many are left. Setting remaining count to 0 hides the basket from customers.")

        Text("Store photo")
            .font(.headline)
        Text("Profile → Store appearance uploads your logo. If My Products still shows an old picture after a change, pull to refresh on that screen.")

        Text("Orders")
            .font(.headline)
        Text("Use the Orders tab for pickup codes and status. Profile → Incoming orders jumps there quickly.")
    }

    @ViewBuilder
    private var customerSections: some View {
        Text("Pickup")
            .font(.headline)
        Text("Bring your order confirmation or pickup code. Arrive inside the venue’s pickup window shown on your basket.")

        Text("Payments & refunds")
            .font(.headline)
        Text("Charges go through when you complete checkout. If an order is cancelled by the venue, you’ll be notified in-app; refunds follow your card issuer’s timing.")

        Text("Favourite stores")
            .font(.headline)
        Text("Heart a store from its page to get alerts when they post new baskets.")

        Text("Venues")
            .font(.headline)
        Text("Partners list surprise baskets at lower prices to cut waste. Offers update when venues publish or edit stock.")
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
        .environment(\.mainTabSelection, MainTabSelection())
}

#Preview("Edit Profile") {
    EditProfileView()
        .environment(AppState())
}
