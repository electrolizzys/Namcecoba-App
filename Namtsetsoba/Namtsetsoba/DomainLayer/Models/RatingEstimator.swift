import Foundation

/// Computes the rating value shown to customers.
///
/// Blends sparse real averages toward a prior (Bayesian / IMDb-style) and
/// estimates a cold-start rating from activity when no reviews exist yet.
enum RatingEstimator {
    static let priorMean: Double = 4.3
    static let priorWeight: Double = 8

    /// Weighted rating: `(v/(v+m))*R + (m/(v+m))*C`.
    static func weightedRating(average: Double, count: Int) -> Double {
        guard count > 0 else { return priorMean }
        let v = Double(count)
        let m = priorWeight
        return (v / (v + m)) * average + (m / (v + m)) * priorMean
    }

    /// Estimate for an unrated store from pickups and average discount (%).
    static func coldStartEstimate(pickedUpOrders: Int, averageSavingsPercent: Int) -> Double {
        let base = 3.8
        let popularityBonus = min(0.6, log10(Double(max(0, pickedUpOrders)) + 1) * 0.35)
        let savingsBonus = min(0.5, Double(max(0, averageSavingsPercent)) / 100.0 * 0.8)
        let estimate = base + popularityBonus + savingsBonus
        return min(4.9, max(3.6, estimate))
    }
}
