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
    }
}

#Preview {
    ContentView()
}
