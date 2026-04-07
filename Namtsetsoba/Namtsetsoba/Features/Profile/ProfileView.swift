import SwiftUI

struct ProfileView: View {
    var onSignOut: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Text("Account info — later")
                Text("Notifications — later")
                Text("Chat — later")

                Section {
                    Button(role: .destructive) {
                        onSignOut()
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView(onSignOut: {})
}
