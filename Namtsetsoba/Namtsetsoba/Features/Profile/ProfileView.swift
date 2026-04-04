import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("Account info — later")
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
