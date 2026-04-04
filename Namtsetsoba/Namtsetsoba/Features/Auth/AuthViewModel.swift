import Foundation

@Observable
final class AuthViewModel {

    // MARK: - User input
    var email = ""
    var password = ""
    var confirmPassword = ""

    // MARK: - UI state
    var isLoading = false
    var errorMessage: String?
    var isLoggedIn = false

    // true = show register form, false = show login form
    var isRegistering = false

    // MARK: - Actions

    func login() {
        guard validateLogin() else { return }

        isLoading = true
        errorMessage = nil

        // Fake delay to simulate network call — will be replaced with Supabase later
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            self.isLoading = false
            self.isLoggedIn = true
        }
    }

    func register() {
        guard validateRegistration() else { return }

        isLoading = true
        errorMessage = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            self.isLoading = false
            self.isLoggedIn = true
        }
    }

    // MARK: - Validation

    private func validateLogin() -> Bool {
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter your email"
            return false
        }
        if password.isEmpty {
            errorMessage = "Please enter your password"
            return false
        }
        return true
    }

    private func validateRegistration() -> Bool {
        if !validateLogin() { return false }
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return false
        }
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        return true
    }
}
