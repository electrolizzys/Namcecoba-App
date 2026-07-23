import Foundation

extension SortOption {
    /// SF Symbol shown next to each sort option.
    var systemImage: String {
        switch self {
        case .price: "banknote"
        case .distance: "location"
        case .topPicks: "heart.fill"
        case .bestDeal: "percent"
        }
    }
}
