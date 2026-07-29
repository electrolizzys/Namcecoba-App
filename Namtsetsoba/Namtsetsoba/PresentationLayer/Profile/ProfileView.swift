import PhotosUI
import SwiftUI
import UIKit

struct ProfileView: View {
    private enum Route: Hashable {
        case favourites
        case impact
        case adminPanel
        case help
        case about
        case changePassword
    }

    @Environment(AppState.self) private var appState
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.mainTabSelection) private var mainTabSelection
    @State private var viewModel = ProfileViewModel()
    @State private var localization = LocalizationManager.shared
    @State private var showEditProfile = false
    @State private var logoPickerItem: PhotosPickerItem?
    @State private var logoUploading = false
    @State private var logoMessage: String?
    @State private var logoMessageIsError = false
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                Section {
                    HStack(spacing: 12) {
                        profileHeaderAvatar
                        VStack(alignment: .leading, spacing: 4) {
                            Text(appState.username.isEmpty ? L(.profileMyAccount) : appState.username)
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

                if appState.currentRole != .admin {
                    Section(L(.profileActivity)) {
                        if appState.currentRole == .business {
                            Button {
                                mainTabSelection?.openMyProductsTab()
                            } label: {
                                Label(
                                    String(format: L(.profileActiveBaskets), appState.businessBaskets.count),
                                    systemImage: "storefront.fill"
                                )
                            }

                            Button {
                                mainTabSelection?.openOrders(isBusiness: true)
                            } label: {
                                Label(L(.profileIncomingOrders), systemImage: "bag.fill")
                            }
                        } else {
                            Button {
                                mainTabSelection?.openOrders(isBusiness: false)
                            } label: {
                                Label(
                                    String(format: L(.profileOrdersPlaced), appState.orders.count),
                                    systemImage: "bag.fill"
                                )
                            }

                            NavigationLink(value: Route.favourites) {
                                Label(
                                    String(format: L(.profileFavoriteStores), appState.frequentStoreIds.count),
                                    systemImage: "heart.fill"
                                )
                            }

                            NavigationLink(value: Route.impact) {
                                Label(L(.profileMyImpact), systemImage: "chart.bar.xaxis")
                            }
                        }
                    }
                }

                if appState.currentRole == .business {
                    Section(L(.profileStoreAppearance)) {
                        HStack(spacing: 14) {
                            StoreThumbnailView(store: appState.businessStore, size: 72)

                            VStack(alignment: .leading, spacing: 8) {
                                Text(L(.profileStorePhotoHint))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                PhotosPicker(selection: $logoPickerItem, matching: .images) {
                                    Label(
                                        logoUploading ? L(.profileUploading) : L(.profileChooseStorePhoto),
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

                Section(L(.profileSettings)) {
                    Picker(selection: languageBinding) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text("\(lang.flag)  \(lang.displayName)").tag(lang)
                        }
                    } label: {
                        Label(L(.profileLanguage), systemImage: "globe")
                    }
                    .pickerStyle(.menu)
                }

                Section(L(.profileSupport)) {
                    if appState.currentRole == .admin {
                        NavigationLink(value: Route.adminPanel) {
                            Label(L(.profileAdminPanel), systemImage: "shield.lefthalf.filled")
                        }
                    }
                    NavigationLink(value: Route.help) {
                        Label(L(.profileHelpCenter), systemImage: "questionmark.circle")
                    }
                    NavigationLink(value: Route.about) {
                        Label(L(.profileAbout), systemImage: "info.circle")
                    }
                }

                Section(L(.profileAccountSecurity)) {
                    NavigationLink(value: Route.changePassword) {
                        Label(L(.profileChangePassword), systemImage: "lock.rotation")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        authViewModel.signOut()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text(L(.profileSignOut))
                        }
                    }
                }

                FloatingTabBarListFiller.section
            }
            .scrollContentBackground(.hidden)
            .lightGreenScreenStyle()
            .navigationTitle(L(.profileTitle))
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .favourites: FavouriteStoresView()
                case .impact: CustomerAnalyticsView()
                case .adminPanel: AdminPanelView()
                case .help: HelpCenterView()
                case .about: AboutNamtsetsobaView()
                case .changePassword: ChangePasswordView()
                }
            }
            .refreshable {
                _ = await appState.loadUserInfo()
                await appState.loadOrders()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
        }
        .onTabRootReset {
            navigationPath = NavigationPath()
            showEditProfile = false
        }
    }

    private var languageBinding: Binding<AppLanguage> {
        Binding(
            get: { localization.language },
            set: { localization.language = $0 }
        )
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
            logoMessage = L(.profileCouldNotReadImage)
            logoMessageIsError = true
            logoPickerItem = nil
            return
        }

        do {
            let result = try await viewModel.uploadLogo(storeId: appState.businessStore.id, jpegData: jpeg)
            if let refreshed = result.store {
                appState.businessStore = refreshed
                appState.businessBaskets = result.baskets
            }
            logoMessage = L(.profileStorePhotoUpdated)
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
    @State private var viewModel = ProfileViewModel()
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
                List {
                    ForEach(favouriteStores) { store in
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

                    FloatingTabBarListFiller.section
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favourite stores")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            allStores = await viewModel.loadStores()
            didAttemptLoad = true
        }
        .refreshable {
            allStores = await viewModel.loadStores()
        }
    }
}

// MARK: - Edit Profile

struct EditProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ProfileViewModel()
    @State private var newUsername = ""
    @State private var isSaving = false
    @State private var message: String?

    var body: some View {
        NavigationStack {
            Form {
                Section(L(.authUsername)) {
                    TextField(L(.authUsername), text: $newUsername)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                Section(L(.authEmail)) {
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
            .navigationTitle(L(.profileMyAccount))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L(.commonCancel)) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L(.commonSave)) { saveUsername() }
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
                try await viewModel.updateUsername(trimmed)
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
