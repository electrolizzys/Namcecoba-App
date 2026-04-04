import SwiftUI

struct SearchView: View {
    @State private var query = ""

    var body: some View {
        NavigationStack {
            List {
                Text("Search by store name — wire to Supabase later")
            }
            .navigationTitle("Search")
            .searchable(text: $query, prompt: "Store name")
        }
    }
}

#Preview {
    SearchView()
}
