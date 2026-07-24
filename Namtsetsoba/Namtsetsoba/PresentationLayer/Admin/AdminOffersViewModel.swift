import Foundation
import Observation

@Observable
final class AdminOffersViewModel {
    var offers: [Basket] = []
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored private let fetchOffers: FetchAdminOffersUseCase

    init(container: AppContainer = .shared) {
        fetchOffers = container.fetchAdminOffers
    }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            offers = try await fetchOffers.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
