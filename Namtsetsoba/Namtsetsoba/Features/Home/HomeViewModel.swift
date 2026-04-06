import Foundation
import Observation

@Observable
final class HomeViewModel {
    var allBaskets: [Basket] = []
    var selectedSort: SortOption = .price
    var selectedCategory: ProductCategory? = nil
    var searchQuery: String = ""
    var isLoading = false
    var frequentStoreIds: Set<UUID> = []

    var filteredBaskets: [Basket] {
        var result = allBaskets

        if !searchQuery.isEmpty {
            result = result.filter {
                $0.store.name.localizedCaseInsensitiveContains(searchQuery) ||
                $0.title.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        if let category = selectedCategory {
            result = result.filter { $0.store.category == category }
        }

        switch selectedSort {
        case .price:
            result.sort { $0.discountedPrice < $1.discountedPrice }
        case .distance:
            result.sort { ($0.distanceKm ?? .infinity) < ($1.distanceKm ?? .infinity) }
        case .topPicks:
            result.sort { lhs, rhs in
                let lFreq = frequentStoreIds.contains(lhs.store.id)
                let rFreq = frequentStoreIds.contains(rhs.store.id)
                if lFreq != rFreq { return lFreq }
                return lhs.discountedPrice < rhs.discountedPrice
            }
        case .bestDeal:
            result.sort { $0.savingsPercent > $1.savingsPercent }
        }

        return result
    }

    @MainActor
    func loadBaskets() async {
        isLoading = true
        allBaskets = await BasketService.shared.fetchAvailableBaskets()
        isLoading = false
    }
}
