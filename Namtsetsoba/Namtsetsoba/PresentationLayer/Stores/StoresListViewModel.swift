import Foundation
import Observation

/// Sort options for the Stores list.
enum StoreSortOption: String, CaseIterable, Identifiable {
    case rating = "Top Rated"
    case name = "Name"
    case openNow = "Open Now"
    case distance = "Distance"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .rating: "star.fill"
        case .name: "textformat"
        case .openNow: "clock.fill"
        case .distance: "location.fill"
        }
    }
}

/// Loads and filters the list of stores for the Stores tab.
@Observable
final class StoresListViewModel {
    var allStores: [Store] = []
    var isLoading = false

    // Filter / sort state (driven by the header controls).
    var searchQuery = ""
    var selectedCategory: ProductCategory?
    var selectedSort: StoreSortOption = .rating
    var showFavouritesOnly = false
    var favouriteStoreIds: Set<UUID> = []

    @ObservationIgnored private let fetchStoresUseCase: FetchStoresUseCase

    init(container: AppContainer = .shared) {
        fetchStoresUseCase = container.fetchStores
    }

    var sortLabel: String {
        showFavouritesOnly ? "Favourites" : selectedSort.rawValue
    }

    var filteredStores: [Store] {
        var result = allStores

        if !searchQuery.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery) ||
                $0.address.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        if showFavouritesOnly {
            result = result.filter { favouriteStoreIds.contains($0.id) }
        }

        switch selectedSort {
        case .rating:
            result.sort { $0.displayRating > $1.displayRating }
        case .name:
            result.sort { $0.name < $1.name }
        case .openNow:
            result.sort { lhs, rhs in
                if lhs.isOpenNow != rhs.isOpenNow { return lhs.isOpenNow }
                return lhs.displayRating > rhs.displayRating
            }
        case .distance:
            result.sort {
                (LocationManager.shared.distanceToStore($0) ?? .infinity) <
                (LocationManager.shared.distanceToStore($1) ?? .infinity)
            }
        }

        return result
    }

    @MainActor
    func loadStores() async {
        isLoading = allStores.isEmpty
        allStores = (try? await fetchStoresUseCase.execute()) ?? []
        isLoading = false
    }
}
