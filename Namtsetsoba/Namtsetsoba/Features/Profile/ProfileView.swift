import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Account / Auth") {
                    AuthView()
                }
                Text("Notifications — later")
                Text("Chat — later")
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}
