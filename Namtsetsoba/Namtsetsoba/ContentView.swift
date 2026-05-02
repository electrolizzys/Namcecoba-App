import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()
    @State private var authViewModel = AuthViewModel()
    @State private var mainTabSelection = MainTabSelection()
    private var locationManager = LocationManager.shared

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                MainTabView(mainTabSelection: mainTabSelection)
                    .environment(appState)
                    .environment(authViewModel)
                    .environment(locationManager)
                    .environment(\.mainTabSelection, mainTabSelection)
            } else {
                AuthView(viewModel: authViewModel)
            }
        }
        .animation(.easeInOut, value: authViewModel.isLoggedIn)
        .onAppear {
            locationManager.requestPermission()
        }
        .onChange(of: authViewModel.isLoggedIn) { _, loggedIn in
            if loggedIn {
                Task {
                    await appState.loadUserInfo()
                    await appState.loadOrders()
                    await appState.loadNotifications()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
