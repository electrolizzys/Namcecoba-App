import SwiftUI

struct ContentView: View {
    @State private var viewModel = AuthViewModel()

    var body: some View {
        Group {
            if viewModel.isLoggedIn {
                MainTabView()
            } else {
                AuthView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
