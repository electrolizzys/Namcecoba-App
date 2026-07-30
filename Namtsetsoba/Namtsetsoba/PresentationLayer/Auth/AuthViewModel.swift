import Foundation
import Observation

/// Presentation logic for the authentication screens.
@Observable
final class AuthViewModel {

    // MARK: - User input
    var email = "" {
        didSet { clearBannersIfNeeded(oldValue: oldValue, newValue: email) }
    }
    var username = "" {
        didSet { clearBannersIfNeeded(oldValue: oldValue, newValue: username) }
    }
    var password = "" {
        didSet { clearBannersIfNeeded(oldValue: oldValue, newValue: password) }
    }
    var confirmPassword = "" {
        didSet { clearBannersIfNeeded(oldValue: oldValue, newValue: confirmPassword) }
    }
    var resetEmail = "" {
        didSet { clearBannersIfNeeded(oldValue: oldValue, newValue: resetEmail) }
    }

    // MARK: - UI state
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?
    var isLoggedIn = false

    var currentScreen: AuthScreen = .login

    enum AuthScreen {
        case login
        case register
        case forgotPassword
    }

    // MARK: - Dependencies
    @ObservationIgnored private let signInUseCase: SignInUseCase
    @ObservationIgnored private let signUpUseCase: SignUpUseCase
    @ObservationIgnored private let sendPasswordResetUseCase: SendPasswordResetUseCase
    @ObservationIgnored private var bannerClearTask: Task<Void, Never>?

    init(container: AppContainer = .shared) {
        signInUseCase = container.signIn
        signUpUseCase = container.signUp
        sendPasswordResetUseCase = container.sendPasswordReset
    }

    // MARK: - Sign In

    func login() {
        guard validateLogin() else { return }
        isLoading = true
        clearBanners()

        Task { @MainActor in
            do {
                try await signInUseCase.execute(email: email, password: password)
                isLoggedIn = true
            } catch {
                setError(String(format: L(.authLoginFailed), error.localizedDescription))
            }
            isLoading = false
        }
    }

    // MARK: - Register

    func register() {
        guard validateRegistration() else { return }
        isLoading = true
        clearBanners()

        Task { @MainActor in
            do {
                try await signUpUseCase.execute(email: email, password: password, username: username)
                currentScreen = .login
                password = ""
                confirmPassword = ""
                username = ""
                setSuccess(L(.authRegisterSuccess))
            } catch {
                setError(String(format: L(.authRegisterFailed), error.localizedDescription))
            }
            isLoading = false
        }
    }

    // MARK: - Forgot Password

    func sendPasswordReset() {
        let trimmed = resetEmail.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            setError(L(.authEnterEmail))
            return
        }

        isLoading = true
        clearBanners()

        Task { @MainActor in
            do {
                try await sendPasswordResetUseCase.execute(email: trimmed)
                currentScreen = .login
                resetEmail = ""
                setSuccess(L(.authResetSuccess))
            } catch {
                setError(String(format: L(.authResetFailed), error.localizedDescription))
            }
            isLoading = false
        }
    }

    // MARK: - Sign Out

    func signOut() {
        isLoggedIn = false
    }

    func clearBanners() {
        bannerClearTask?.cancel()
        bannerClearTask = nil
        errorMessage = nil
        successMessage = nil
    }

    // MARK: - Validation

    private func validateLogin() -> Bool {
        clearBanners()
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            setError(L(.authEnterEmail))
            return false
        }
        if password.isEmpty {
            setError(L(.authEnterPassword))
            return false
        }
        return true
    }

    private func validateRegistration() -> Bool {
        if !validateLogin() { return false }
        if username.trimmingCharacters(in: .whitespaces).isEmpty {
            setError(L(.authEnterUsername))
            return false
        }
        if password.count < 6 {
            setError(L(.authPasswordTooShort))
            return false
        }
        if password != confirmPassword {
            setError(L(.authPasswordsMismatch))
            return false
        }
        return true
    }

    private func clearBannersIfNeeded(oldValue: String, newValue: String) {
        guard oldValue != newValue else { return }
        guard errorMessage != nil || successMessage != nil else { return }
        clearBanners()
    }

    private func setError(_ message: String) {
        bannerClearTask?.cancel()
        errorMessage = message
        successMessage = nil
        scheduleBannerAutoClear()
    }

    private func setSuccess(_ message: String) {
        bannerClearTask?.cancel()
        successMessage = message
        errorMessage = nil
        scheduleBannerAutoClear()
    }

    private func scheduleBannerAutoClear() {
        bannerClearTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            errorMessage = nil
            successMessage = nil
        }
    }
}
