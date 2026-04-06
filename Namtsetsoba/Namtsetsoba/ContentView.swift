import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()

    var body: some View {
        MainTabView()
            .environment(appState)
    }
}

#Preview {
    ContentView()
}
