import SwiftUI

struct BasketDetailView: View {
    let basket: BasketSummary

    var body: some View {
        List {
            Section("Basket") {
                Text(basket.title)
                Text(Utilities.formatMoneyGel(basket.priceGel))
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        BasketDetailView(
            basket: BasketSummary(id: UUID(), title: "Sample basket", priceGel: 9.99)
        )
    }
}
