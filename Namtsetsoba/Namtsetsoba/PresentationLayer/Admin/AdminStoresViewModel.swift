import Foundation
import Observation

@Observable
final class AdminStoresViewModel {
    var stores: [Store] = []
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored private let fetchStores: FetchStoresUseCase

    init(container: AppContainer = .shared) {
        fetchStores = container.fetchStores
    }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            stores = try await fetchStores.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
