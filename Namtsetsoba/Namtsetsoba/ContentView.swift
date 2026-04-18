import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()
    @State private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainTabView()
                    .environment(appState)
                    .environment(authViewModel)
            } else {
                AuthView(viewModel: authViewModel)
            }
        }
        .animation(.easeInOut, value: authViewModel.isLoggedIn)
        .onChange(of: authViewModel.isLoggedIn) { _, loggedIn in
            if loggedIn {
                Task {
                    await appState.loadUserInfo()
                    await appState.loadOrders()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
