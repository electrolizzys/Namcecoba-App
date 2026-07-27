import Foundation

/// Sorting strategy for the customer offers feed.
///
/// The icon used to represent each option lives in `SortOption+Presentation`.
enum SortOption: String, CaseIterable, Identifiable {
    case price = "Price"
    case rating = "Top Rated"
    case distance = "Distance"
    case topPicks = "Your Favorites"
    case bestDeal = "Best Deals"

    var id: String { rawValue }
}
