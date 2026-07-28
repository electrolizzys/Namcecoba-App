import Foundation

extension SortOption {
    /// Localized, user-facing sort label.
    var localizedName: String {
        switch self {
        case .price: L(.sortPrice)
        case .rating: L(.sortTopRated)
        case .distance: L(.sortDistance)
        case .topPicks: L(.sortFavorites)
        case .bestDeal: L(.sortBestDeals)
        }
    }

    /// SF Symbol shown next to each sort option.
    var systemImage: String {
        switch self {
        case .price: "banknote"
        case .rating: "star.fill"
        case .distance: "location"
        case .topPicks: "heart.fill"
        case .bestDeal: "percent"
        }
    }
}
