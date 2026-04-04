import SwiftUI

struct OrdersView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("Active orders — later")
                Text("History — later")
            }
            .navigationTitle("Orders")
        }
    }
}

#Preview {
    OrdersView()
}
