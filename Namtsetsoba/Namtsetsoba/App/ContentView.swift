import SwiftUI

private enum AuthPhase {
    case checking
    case signingOut
    case signedOut
    case signedIn
}

struct ContentView: View {
    @State private var appState = AppState()
    @State private var authViewModel = AuthViewModel()
    @State private var mainTabSelection = MainTabSelection()
    @State private var authPhase: AuthPhase = .checking
    private var locationManager = LocationManager.shared
    private var localization = LocalizationManager.shared

    var body: some View {
        Group {
            switch authPhase {
            case .checking:
                startupLoadingView
            case .signingOut:
                signingOutView
            case .signedOut:
                AuthView(viewModel: authViewModel)
            case .signedIn:
                MainTabView(mainTabSelection: mainTabSelection)
                    .environment(appState)
                    .environment(authViewModel)
                    .environment(locationManager)
                    .environment(\.mainTabSelection, mainTabSelection)
            }
        }
        // Re-identify the tree when the language changes so every `L(...)` lookup
        // is re-evaluated immediately (no restart needed).
        .id(localization.language)
        .environment(\.locale, localization.locale)
        .onAppear {
            locationManager.requestPermission()
        }
        .task {
            await resolveAuthState()
        }
        .onChange(of: authViewModel.isLoggedIn) { _, loggedIn in
            if loggedIn {
                guard authPhase == .signedOut else { return }
                Task { await resolveAuthState() }
            } else {
                // Show a blocking loader immediately so taps can't fall through to
                // the tab bar while the async sign-out completes.
                guard authPhase == .signedIn else { return }
                authPhase = .signingOut
                Task { await completeSignOut() }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .pushNotificationTapped)) { _ in
            PushNotificationManager.shared.applyPendingNavigation(
                appState: appState,
                tabSelection: mainTabSelection
            )
        }
    }

    private var startupLoadingView: some View {
        ZStack {
            DesignTokens.primaryGreen
                .ignoresSafeArea()
            ProgressView(L(.commonLoading))
                .tint(.white)
                .foregroundStyle(.white)
        }
    }

    private var signingOutView: some View {
        ZStack {
            DesignTokens.primaryGreen
                .ignoresSafeArea()
            ProgressView(L(.authSigningOut))
                .tint(.white)
                .foregroundStyle(.white)
        }
    }

    /// Validates session, loads profile/role, then opens the app — or sends user to sign in.
    @MainActor
    private func resolveAuthState() async {
        authPhase = .checking

        do {
            _ = try await AppContainer.shared.getCurrentUser.execute()

            guard await appState.loadUserInfo() else {
                await completeSignOut()
                return
            }

            authViewModel.isLoggedIn = true
            authPhase = .signedIn
            await loadRemainingSignedInData()
        } catch {
            await completeSignOut()
        }
    }

    @MainActor
    private func completeSignOut() async {
        guard authPhase != .signedOut else { return }

        // Fully clear the remote session/token first so the next launch can't
        // silently restore the session and "undo" the sign-out.
        await PushNotificationManager.shared.clearTokenOnSignOut()
        try? await AppContainer.shared.signOut.execute()
        appState.resetForSignOut()
        authViewModel.isLoggedIn = false
        authPhase = .signedOut
    }

    @MainActor
    private func loadRemainingSignedInData() async {
        await appState.loadOrders()
        await appState.loadNotifications()

        try? await Task.sleep(for: .milliseconds(600))
        await PushNotificationManager.shared.requestAuthorizationAndRegister()
        PushNotificationManager.shared.applyPendingNavigation(
            appState: appState,
            tabSelection: mainTabSelection
        )
    }
}
