import SwiftUI

// MARK: - About

struct AboutNamtsetsobaView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(DesignTokens.headerGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                    Text("Namtsetsoba")
                        .font(.title.bold())
                    Text(L(.aboutHero))
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)

                aboutCard(title: L(.aboutHowTitle), body: L(.aboutHowBody), icon: "bag.fill")
                aboutCard(title: L(.aboutWhereTitle), body: L(.aboutWhereBody), icon: "mappin.and.ellipse")
                aboutCard(title: L(.aboutWhyTitle), body: L(.aboutWhyBody), icon: "heart.fill")
                aboutCard(title: L(.aboutVersionTitle), body: L(.aboutVersionBody), icon: "hammer.fill")

                Text(L(.aboutThanks))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(DesignTokens.padding)
            .floatingTabBarScrollFiller()
        }
        .background(DesignTokens.selectedChipBackground)
        .navigationTitle(L(.aboutTitle))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func aboutCard(title: String, body: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(DesignTokens.primaryGreen)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

// MARK: - Help

struct HelpCenterView: View {
    @Environment(AppState.self) private var appState
    @State private var supportMessage = ""
    @State private var isSending = false
    @State private var banner: String?
    @State private var bannerIsError = false
    @State private var bannerClearTask: Task<Void, Never>?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(L(.helpTitle))
                    .font(.title2.bold())

                if appState.currentRole == .business {
                    helpCard(L(.helpVenueAccountTitle), L(.helpVenueAccountBody), "storefront.fill")
                    helpCard(L(.helpVenueEditTitle), L(.helpVenueEditBody), "square.and.pencil")
                    helpCard(L(.helpVenuePhotoTitle), L(.helpVenuePhotoBody), "photo")
                    helpCard(L(.helpVenueOrdersTitle), L(.helpVenueOrdersBody), "bag.fill")
                } else if appState.currentRole == .customer {
                    helpCard(L(.helpCustomerPickupTitle), L(.helpCustomerPickupBody), "checkmark.seal.fill")
                    helpCard(L(.helpCustomerPayTitle), L(.helpCustomerPayBody), "creditcard.fill")
                    helpCard(L(.helpCustomerFavTitle), L(.helpCustomerFavBody), "heart.fill")
                    helpCard(L(.helpCustomerVenuesTitle), L(.helpCustomerVenuesBody), "leaf.fill")
                }

                Text(L(.helpNeedMore))
                    .font(.headline)
                Text(appState.currentRole == .business ? L(.helpVenueContact) : L(.helpCustomerContact))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if appState.currentRole != .admin {
                    supportCard
                }
            }
            .padding(DesignTokens.padding)
            .floatingTabBarScrollFiller()
        }
        .background(DesignTokens.selectedChipBackground)
        .navigationTitle(L(.helpTitle))
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            bannerClearTask?.cancel()
            bannerClearTask = nil
        }
    }

    private var supportCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(L(.helpSupportTitle), systemImage: "lifepreserver.fill")
                .font(.headline)
                .foregroundStyle(DesignTokens.primaryGreen)
            Text(L(.helpSupportSubtitle))
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField(L(.helpSupportPlaceholder), text: $supportMessage, axis: .vertical)
                .lineLimit(4...8)
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .onChange(of: supportMessage) { _, newValue in
                    // Clear leftover banners once the user starts typing again.
                    guard banner != nil, !newValue.isEmpty else { return }
                    Task { @MainActor in clearBanner() }
                }

            if let banner {
                Text(banner)
                    .font(.caption)
                    .foregroundStyle(bannerIsError ? .red : DesignTokens.primaryGreen)
                    .transition(.opacity)
            }

            Button {
                Task { await sendSupport() }
            } label: {
                ZStack {
                    if isSending {
                        ProgressView().tint(.white)
                    } else {
                        Text(L(.helpSupportSend))
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .foregroundStyle(.white)
                .background(DesignTokens.headerGradient)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isSending)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    private func helpCard(_ title: String, _ body: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    @MainActor
    private func sendSupport() async {
        let trimmed = supportMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 3 else {
            showBanner(L(.helpSupportEmpty), isError: true)
            return
        }
        isSending = true
        clearBanner()
        defer { isSending = false }
        do {
            try await AppContainer.shared.submitSupportRequest.execute(message: trimmed)
            supportMessage = ""
            showBanner(L(.helpSupportSent), isError: false)
        } catch {
            let detail = error.localizedDescription
            let needsSetup =
                detail.localizedCaseInsensitiveContains("could not find")
                || detail.localizedCaseInsensitiveContains("does not exist")
                || detail.localizedCaseInsensitiveContains("404")
                || detail.localizedCaseInsensitiveContains("PGRST202")
                || detail.localizedCaseInsensitiveContains("function")
            let text = needsSetup
                ? "\(L(.helpSupportFailed)) Run docs/support_setup.sql in Supabase."
                : "\(L(.helpSupportFailed)) (\(detail))"
            showBanner(text, isError: true)
        }
    }

    @MainActor
    private func showBanner(_ text: String, isError: Bool) {
        bannerClearTask?.cancel()
        withAnimation(.easeInOut(duration: 0.2)) {
            banner = text
            bannerIsError = isError
        }
        bannerClearTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                banner = nil
            }
        }
    }

    @MainActor
    private func clearBanner() {
        bannerClearTask?.cancel()
        bannerClearTask = nil
        banner = nil
    }
}

// MARK: - Change Password

struct ChangePasswordView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = ProfileViewModel()
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @State private var isChangingPassword = false
    @State private var passwordMessage: String?
    @State private var passwordMessageIsError = false
    @State private var revealCurrent = false
    @State private var revealNew = false
    @State private var revealConfirm = false
    @State private var messageClearTask: Task<Void, Never>?

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Label(L(.passwordTitle), systemImage: "lock.rotation")
                        .font(.headline)
                        .foregroundStyle(DesignTokens.primaryGreen)
                    Text(L(.passwordHint))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)

                VStack(spacing: 12) {
                    passwordField(L(.passwordCurrent), text: $currentPassword, reveal: $revealCurrent)
                    passwordField(L(.passwordNew), text: $newPassword, reveal: $revealNew)
                    passwordField(L(.passwordConfirm), text: $confirmNewPassword, reveal: $revealConfirm)
                }
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                .onChange(of: currentPassword) { _, _ in
                    Task { @MainActor in clearPasswordMessageIfPresent() }
                }
                .onChange(of: newPassword) { _, _ in
                    Task { @MainActor in clearPasswordMessageIfPresent() }
                }
                .onChange(of: confirmNewPassword) { _, _ in
                    Task { @MainActor in clearPasswordMessageIfPresent() }
                }

                if let passwordMessage {
                    Text(passwordMessage)
                        .font(.caption)
                        .foregroundStyle(passwordMessageIsError ? .red : DesignTokens.primaryGreen)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                }

                Button {
                    Task { await changePassword() }
                } label: {
                    ZStack {
                        if isChangingPassword {
                            ProgressView().tint(.white)
                        } else {
                            Text(L(.passwordUpdate))
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .foregroundStyle(.white)
                    .background(DesignTokens.headerGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: DesignTokens.primaryGreen.opacity(0.3), radius: 10, y: 5)
                }
                .buttonStyle(.plain)
                .disabled(isChangingPassword)
            }
            .padding(DesignTokens.padding)
            .floatingTabBarScrollFiller()
        }
        .background(DesignTokens.selectedChipBackground)
        .navigationTitle(L(.passwordTitle))
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            messageClearTask?.cancel()
            messageClearTask = nil
        }
    }

    private func passwordField(
        _ placeholder: String,
        text: Binding<String>,
        reveal: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .foregroundStyle(.secondary)
                .frame(width: 18)
            Group {
                if reveal.wrappedValue {
                    TextField(placeholder, text: text)
                } else {
                    SecureField(placeholder, text: text)
                }
            }
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            Button {
                reveal.wrappedValue.toggle()
            } label: {
                Image(systemName: reveal.wrappedValue ? "eye.fill" : "eye.slash.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .frame(height: 52)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    @MainActor
    private func changePassword() async {
        clearPasswordMessage()

        let trimmedEmail = appState.userEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            showPasswordMessage(L(.passwordMissingEmail), isError: true)
            return
        }
        guard !currentPassword.isEmpty else {
            showPasswordMessage(L(.passwordEnterCurrent), isError: true)
            return
        }
        guard newPassword.count >= 6 else {
            showPasswordMessage(L(.passwordTooShort), isError: true)
            return
        }
        guard newPassword == confirmNewPassword else {
            showPasswordMessage(L(.passwordMismatch), isError: true)
            return
        }
        guard newPassword != currentPassword else {
            showPasswordMessage(L(.passwordMustDiffer), isError: true)
            return
        }

        isChangingPassword = true
        defer { isChangingPassword = false }

        do {
            try await viewModel.changePassword(
                email: trimmedEmail,
                currentPassword: currentPassword,
                newPassword: newPassword
            )
            currentPassword = ""
            newPassword = ""
            confirmNewPassword = ""
            showPasswordMessage(L(.passwordUpdated), isError: false)
        } catch {
            showPasswordMessage(
                String(format: L(.passwordChangeFailed), error.localizedDescription),
                isError: true
            )
        }
    }

    @MainActor
    private func showPasswordMessage(_ text: String, isError: Bool) {
        messageClearTask?.cancel()
        withAnimation(.easeInOut(duration: 0.2)) {
            passwordMessage = text
            passwordMessageIsError = isError
        }
        messageClearTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                passwordMessage = nil
            }
        }
    }

    @MainActor
    private func clearPasswordMessage() {
        messageClearTask?.cancel()
        messageClearTask = nil
        passwordMessage = nil
    }

    @MainActor
    private func clearPasswordMessageIfPresent() {
        guard passwordMessage != nil else { return }
        // Ignore the empty-field reset after a successful change.
        let anyTyped = !currentPassword.isEmpty || !newPassword.isEmpty || !confirmNewPassword.isEmpty
        guard anyTyped else { return }
        clearPasswordMessage()
    }
}
