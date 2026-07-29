import SwiftUI

struct AuthView: View {
    @Bindable var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            AuthBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    brandHeader
                        .padding(.top, 56)

                    card
                        .padding(.horizontal, 20)

                    Spacer(minLength: 24)
                }
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    // MARK: - Brand header

    private var brandHeader: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 84, height: 84)
                    .overlay(Circle().strokeBorder(.white.opacity(0.5), lineWidth: 1))
                Image(systemName: "leaf.fill")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .shadow(color: .black.opacity(0.15), radius: 12, y: 6)

            VStack(spacing: 6) {
                Text("Namtsetsoba")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(L(.authTagline))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Card

    private var card: some View {
        VStack(spacing: 20) {
            switch viewModel.currentScreen {
            case .login, .register:
                modeSwitcher
                if viewModel.currentScreen == .login {
                    loginForm
                } else {
                    registerForm
                }
            case .forgotPassword:
                forgotPasswordForm
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 24, y: 12)
    }

    // MARK: - Mode switcher (Sign In / Register)

    private var modeSwitcher: some View {
        HStack(spacing: 4) {
            segment(title: L(.authSignIn), isActive: viewModel.currentScreen == .login) {
                switchTo(.login)
            }
            segment(title: L(.authRegister), isActive: viewModel.currentScreen == .register) {
                switchTo(.register)
            }
        }
        .padding(4)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule(style: .continuous))
    }

    private func segment(title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isActive ? .white : .secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background {
                    if isActive {
                        Capsule(style: .continuous)
                            .fill(DesignTokens.headerGradient)
                    }
                }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }

    // MARK: - Login form

    private var loginForm: some View {
        VStack(spacing: 16) {
            AuthField(
                icon: "envelope.fill",
                placeholder: L(.authEmail),
                text: $viewModel.email,
                keyboard: .emailAddress,
                contentType: .username
            )
            AuthField(
                icon: "lock.fill",
                placeholder: L(.authPassword),
                text: $viewModel.password,
                isSecure: true,
                contentType: .password
            )

            HStack {
                Spacer()
                Button(L(.authForgotPassword)) { switchTo(.forgotPassword) }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DesignTokens.primaryGreen)
            }

            messagesSection

            AuthPrimaryButton(title: L(.authSignIn), isLoading: viewModel.isLoading) {
                viewModel.login()
            }
        }
    }

    // MARK: - Register form

    private var registerForm: some View {
        VStack(spacing: 16) {
            AuthField(
                icon: "person.fill",
                placeholder: L(.authUsername),
                text: $viewModel.username,
                contentType: .nickname
            )
            AuthField(
                icon: "envelope.fill",
                placeholder: L(.authEmail),
                text: $viewModel.email,
                keyboard: .emailAddress,
                contentType: .username
            )
            AuthField(
                icon: "lock.fill",
                placeholder: L(.authPassword),
                text: $viewModel.password,
                isSecure: true,
                contentType: .newPassword
            )
            AuthField(
                icon: "lock.rotation",
                placeholder: L(.authConfirmPassword),
                text: $viewModel.confirmPassword,
                isSecure: true,
                contentType: .newPassword
            )

            messagesSection

            AuthPrimaryButton(title: L(.authCreateAccount), isLoading: viewModel.isLoading) {
                viewModel.register()
            }

            Text(L(.authRegisterConsent))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Forgot password form

    private var forgotPasswordForm: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text(L(.authResetTitle))
                    .font(.title3.weight(.bold))
                Text(L(.authResetSubtitle))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)

            AuthField(
                icon: "envelope.fill",
                placeholder: L(.authEmail),
                text: $viewModel.resetEmail,
                keyboard: .emailAddress,
                contentType: .username
            )

            messagesSection

            AuthPrimaryButton(title: L(.authSendResetLink), isLoading: viewModel.isLoading) {
                viewModel.sendPasswordReset()
            }

            Button(L(.authBackToSignIn)) { switchTo(.login) }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(DesignTokens.primaryGreen)
        }
    }

    // MARK: - Messages

    @ViewBuilder
    private var messagesSection: some View {
        if let error = viewModel.errorMessage {
            AuthBanner(text: error, kind: .error)
        }
        if let success = viewModel.successMessage {
            AuthBanner(text: success, kind: .success)
        }
    }

    // MARK: - Helpers

    private func switchTo(_ screen: AuthViewModel.AuthScreen) {
        viewModel.clearBanners()
        withAnimation(.easeInOut(duration: 0.2)) {
            viewModel.currentScreen = screen
        }
    }
}

// MARK: - Components

private struct AuthBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    DesignTokens.primaryGreen,
                    DesignTokens.primaryGreenDark
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            // Soft decorative blobs for depth.
            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 12)
                .offset(x: -140, y: -260)
            Circle()
                .fill(DesignTokens.accentOrange.opacity(0.18))
                .frame(width: 240, height: 240)
                .blur(radius: 18)
                .offset(x: 150, y: -180)
        }
        .ignoresSafeArea()
    }
}

private struct AuthField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var isSecure: Bool = false
    var contentType: UITextContentType?

    @State private var reveal = false
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(focused ? DesignTokens.primaryGreen : .secondary)
                .frame(width: 22)

            Group {
                if isSecure && !reveal {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .focused($focused)
            .keyboardType(keyboard)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textContentType(contentType)

            if isSecure {
                Button {
                    reveal.toggle()
                } label: {
                    // Slash when hidden (password concealed); open eye when revealed.
                    Image(systemName: reveal ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 54)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    focused ? DesignTokens.primaryGreen.opacity(0.85) : Color.black.opacity(0.06),
                    lineWidth: focused ? 1.6 : 1
                )
        )
        .animation(.easeInOut(duration: 0.15), value: focused)
    }
}

private struct AuthPrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(title).font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(.white)
            .background(DesignTokens.headerGradient)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: DesignTokens.primaryGreen.opacity(0.35), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .opacity(isLoading ? 0.85 : 1)
    }
}

private struct AuthBanner: View {
    enum Kind { case error, success }
    let text: String
    let kind: Kind

    private var tint: Color {
        switch kind {
        case .error: Color.red
        case .success: DesignTokens.primaryGreen
        }
    }

    private var icon: String {
        switch kind {
        case .error: "exclamationmark.triangle.fill"
        case .success: "checkmark.circle.fill"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
            Text(text)
                .font(.footnote.weight(.medium))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(tint)
        .padding(12)
        .background(tint.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
