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
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.oneTimeCode)
            }
            .padding(.horizontal)

            messagesSection

            Button {
                viewModel.login()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .disabled(viewModel.isLoading)

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
                TextField("Username", text: $viewModel.username)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)

                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.oneTimeCode)

                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.oneTimeCode)
            }
            .padding(.horizontal)

            messagesSection

            Button {
                viewModel.register()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .disabled(viewModel.isLoading)

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

            TextField("Email", text: $viewModel.resetEmail)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            messagesSection

            Button {
                viewModel.sendPasswordReset()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Send Reset Link")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .disabled(viewModel.isLoading)

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
