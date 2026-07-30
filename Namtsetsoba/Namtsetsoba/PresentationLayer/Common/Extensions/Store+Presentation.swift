import Foundation

extension Store {
    /// Customer-facing rating (Bayesian blend of average + prior).
    var displayRating: Double {
        RatingEstimator.weightedRating(average: rating, count: ratingCount)
    }

    var displayRatingText: String {
        String(format: "%.1f", displayRating)
    }

    var ratingCountText: String {
        ratingCount == 0 ? L(.commonNew) : "(\(ratingCount))"
    }
}
