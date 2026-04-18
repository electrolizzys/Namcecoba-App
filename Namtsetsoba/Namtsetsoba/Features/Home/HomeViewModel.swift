import Foundation
import CoreLocation
import Observation

@Observable
final class HomeViewModel {
    var allBaskets: [Basket] = []
    var selectedSort: SortOption = .price
    var selectedCategory: ProductCategory? = nil
    var selectedStoreId: UUID? = nil
    var searchQuery: String = ""
    var isLoading = false
    var frequentStoreIds: Set<UUID> = []
    var userLocation: CLLocationCoordinate2D?

    func distanceToStore(_ store: Store) -> Double? {
        guard let user = userLocation else { return nil }
        let userLoc = CLLocation(latitude: user.latitude, longitude: user.longitude)
        let storeLoc = CLLocation(latitude: store.latitude, longitude: store.longitude)
        return userLoc.distance(from: storeLoc) / 1000.0
    }

    var availableStores: [Store] {
        let seen = NSMutableOrderedSet()
        var stores: [Store] = []
        for basket in allBaskets {
            if !seen.contains(basket.store.id) {
                seen.add(basket.store.id)
                stores.append(basket.store)
            }
        }
        return stores
    }

    var filteredBaskets: [Basket] {
        var result = allBaskets

        if !searchQuery.isEmpty {
            result = result.filter {
                $0.store.name.localizedCaseInsensitiveContains(searchQuery) ||
                $0.title.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        if let storeId = selectedStoreId {
            result = result.filter { $0.store.id == storeId }
        }

        if let category = selectedCategory {
            result = result.filter { $0.store.category == category }
        }

        switch selectedSort {
        case .price:
            result.sort { $0.discountedPrice < $1.discountedPrice }
        case .distance:
            result.sort {
                (distanceToStore($0.store) ?? .infinity) < (distanceToStore($1.store) ?? .infinity)
            }
        case .topPicks:
            result = result.filter { frequentStoreIds.contains($0.store.id) }
            result.sort { $0.discountedPrice < $1.discountedPrice }
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
