import Foundation
import Observation

/// Loads the available baskets for a single store.
@Observable
final class StoreDetailViewModel {
    var baskets: [Basket] = []
    var isLoading = true

    @ObservationIgnored private let fetchAvailableBasketsUseCase: FetchAvailableBasketsUseCase

    init(container: AppContainer = .shared) {
        fetchAvailableBasketsUseCase = container.fetchAvailableBaskets
    }

    @MainActor
    func loadBaskets(storeId: UUID) async {
        isLoading = baskets.isEmpty
        let all = (try? await fetchAvailableBasketsUseCase.execute()) ?? []
        baskets = all.filter { $0.store.id == storeId }
        isLoading = false
    }
}
