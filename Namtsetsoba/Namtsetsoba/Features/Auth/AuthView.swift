import SwiftUI

struct AuthView: View {
    @Bindable var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            switch viewModel.currentScreen {
            case .login:
                loginContent
            case .register:
                registerContent
            case .forgotPassword:
                forgotPasswordContent
            }
        }
    }

    // MARK: - Login Screen

    private var loginContent: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Namtsetsoba")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Sign In")
                .font(.title2)
                .foregroundStyle(.secondary)

            VStack(spacing: 16) {
                AuthInputField(
                    title: "Email",
                    text: $viewModel.email,
                    keyboard: .emailAddress
                )
                AuthInputField(
                    title: "Password",
                    text: $viewModel.password,
                    secure: true,
                    contentType: .oneTimeCode
                )
            }
            .padding(.horizontal)

            messagesSection

            AuthSubmitButton(title: "Sign In", isLoading: viewModel.isLoading) {
                viewModel.login()
            }
            .padding(.horizontal)

            Button("Forgot Password?") {
                viewModel.errorMessage = nil
                viewModel.successMessage = nil
                viewModel.currentScreen = .forgotPassword
            }
            .font(.footnote)

            Button("Don't have an account? Register") {
                viewModel.errorMessage = nil
                viewModel.successMessage = nil
                viewModel.currentScreen = .register
            }
            .font(.footnote)

            Spacer()
        }
    }

    // MARK: - Register Screen

    private var registerContent: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                AuthInputField(title: "Username", text: $viewModel.username)
                AuthInputField(
                    title: "Email",
                    text: $viewModel.email,
                    keyboard: .emailAddress
                )
                AuthInputField(
                    title: "Password",
                    text: $viewModel.password,
                    secure: true,
                    contentType: .oneTimeCode
                )
                AuthInputField(
                    title: "Confirm Password",
                    text: $viewModel.confirmPassword,
                    secure: true,
                    contentType: .oneTimeCode
                )
            }
            .padding(.horizontal)

            messagesSection

            AuthSubmitButton(title: "Register", isLoading: viewModel.isLoading) {
                viewModel.register()
            }
            .padding(.horizontal)

            Button("Already have an account? Sign In") {
                viewModel.errorMessage = nil
                viewModel.successMessage = nil
                viewModel.currentScreen = .login
            }
            .font(.footnote)

            Spacer()
        }
    }

    // MARK: - Forgot Password Screen

    private var forgotPasswordContent: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Reset Password")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Enter your email and we'll send a reset link")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            AuthInputField(
                title: "Email",
                text: $viewModel.resetEmail,
                keyboard: .emailAddress
            )
                .padding(.horizontal)

            messagesSection

            AuthSubmitButton(title: "Send Reset Link", isLoading: viewModel.isLoading) {
                viewModel.sendPasswordReset()
            }
            .padding(.horizontal)

            Button("Back to Sign In") {
                viewModel.errorMessage = nil
                viewModel.successMessage = nil
                viewModel.currentScreen = .login
            }
            .font(.footnote)

            Spacer()
        }
    }

    // MARK: - Shared messages (error + success)

    private var messagesSection: some View {
        VStack(spacing: 4) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            if let success = viewModel.successMessage {
                Text(success)
                    .foregroundStyle(.green)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel())
}
