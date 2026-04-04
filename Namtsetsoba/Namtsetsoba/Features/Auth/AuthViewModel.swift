import Foundation
import Supabase

@Observable
final class AuthViewModel {

    // MARK: - User input
    var email = ""
    var username = ""
    var password = ""
    var confirmPassword = ""
    var resetEmail = ""

    // MARK: - UI state
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?
    var isLoggedIn = false

    // Which screen is showing: .login, .register, or .forgotPassword
    var currentScreen: AuthScreen = .login

    enum AuthScreen {
        case login
        case register
        case forgotPassword
    }

    // MARK: - Sign In

    func login() {
        guard validateLogin() else { return }

        isLoading = true
        errorMessage = nil

        Task { @MainActor in
            do {
                try await supabase.auth.signIn(
                    email: email,
                    password: password
                )
                isLoggedIn = true
            } catch {
                errorMessage = "Login failed. Check your email and password."
            }
            isLoading = false
        }
    }

    // MARK: - Register

    func register() {
        guard validateRegistration() else { return }

        isLoading = true
        errorMessage = nil

        Task { @MainActor in
            do {
                try await supabase.auth.signUp(
                    email: email,
                    password: password,
                    data: ["username": .string(username)]
                )

                successMessage = "Check your email for a verification link!"
                currentScreen = .login
                password = ""
                confirmPassword = ""
                username = ""
            } catch {
                errorMessage = "Registration failed. Try a different email."
            }
            isLoading = false
        }
    }

    // MARK: - Forgot Password

    func sendPasswordReset() {
        let trimmed = resetEmail.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }

        isLoading = true
        errorMessage = nil

        Task { @MainActor in
            do {
                try await supabase.auth.resetPasswordForEmail(trimmed)
                successMessage = "Password reset link sent! Check your email."
                currentScreen = .login
                resetEmail = ""
            } catch {
                errorMessage = "Could not send reset link. Check the email address."
            }
            isLoading = false
        }
    }

    // MARK: - Validation

    private func validateLogin() -> Bool {
        errorMessage = nil
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
        if username.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter a username"
            return false
        }
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return false
        }
        return true
    }
}
