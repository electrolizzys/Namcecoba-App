import SwiftUI

struct AuthView: View {
    var body: some View {
        Text("Auth")
            .navigationTitle("Sign in")
    }
}

#Preview {
    NavigationStack {
        AuthView()
    }
}
