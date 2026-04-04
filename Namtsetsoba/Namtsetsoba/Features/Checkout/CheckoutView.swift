import SwiftUI

struct CheckoutView: View {
    var body: some View {
        Text("Checkout (demo payment later)")
            .padding()
            .navigationTitle("Checkout")
    }
}

#Preview {
    NavigationStack {
        CheckoutView()
    }
}
