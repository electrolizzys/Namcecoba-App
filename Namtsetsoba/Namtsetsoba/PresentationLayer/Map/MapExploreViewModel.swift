import Foundation
import Observation

/// Loads stores for the explore map.
@Observable
final class MapExploreViewModel {
    var allStores: [Store] = []
    var isLoading = true

    @ObservationIgnored private let fetchStoresUseCase: FetchStoresUseCase

    init(container: AppContainer = .shared) {
        fetchStoresUseCase = container.fetchStores
    }

    @MainActor
    func loadStores() async {
        isLoading = true
        allStores = (try? await fetchStoresUseCase.execute()) ?? []
        isLoading = false
    }
}
