import Foundation

extension Store {
    /// Rating shown to customers.
    ///
    /// Real customer feedback drives the number as soon as it exists, blended
    /// toward a neutral prior so a single review can't over/under-rank a store
    /// (Bayesian weighted rating). Before any feedback exists the weighted
    /// rating falls back to the prior mean, so an unrated store is never shown
    /// as `0.0` — it appears as a believable "new store" baseline instead.
    var displayRating: Double {
        RatingEstimator.weightedRating(average: rating, count: ratingCount)
    }

    /// One-decimal string for the display rating (e.g. "4.6").
    var displayRatingText: String {
        String(format: "%.1f", displayRating)
    }

    /// Compact ratings-count label, e.g. "(128)" or "New" when unrated.
    var ratingCountText: String {
        ratingCount == 0 ? "New" : "(\(ratingCount))"
    }
}
