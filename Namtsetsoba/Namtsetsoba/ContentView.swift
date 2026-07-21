import SwiftUI
import Supabase

private enum AuthPhase {
    case checking
    case signedOut
    case signedIn
}

struct ContentView: View {
    @State private var appState = AppState()
    @State private var authViewModel = AuthViewModel()
    @State private var mainTabSelection = MainTabSelection()
    @State private var authPhase: AuthPhase = .checking
    private var locationManager = LocationManager.shared

    var body: some View {
        Group {
            switch authPhase {
            case .checking:
                startupLoadingView
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
            ProgressView("Loading…")
                .tint(.white)
                .foregroundStyle(.white)
        }
    }

    /// Validates session, loads profile/role, then opens the app — or sends user to sign in.
    @MainActor
    private func resolveAuthState() async {
        authPhase = .checking

        do {
            _ = try await supabase.auth.session

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

        await PushNotificationManager.shared.clearTokenOnSignOut()
        try? await supabase.auth.signOut()
        authViewModel.isLoggedIn = false
        appState.resetForSignOut()
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

#Preview {
    ContentView()
}
