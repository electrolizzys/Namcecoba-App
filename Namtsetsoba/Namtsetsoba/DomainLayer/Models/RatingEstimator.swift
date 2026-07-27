import Foundation

/// Computes the rating value shown to customers.
///
/// Real star ratings are sparse early on, so a raw average is noisy and unfair
/// (one 5-star review would rank a brand-new store above an established one).
/// We solve this two ways:
///
/// 1. **Bayesian weighted rating** (IMDb Top-250 style): blend the store's real
///    average toward a global prior until enough ratings accumulate.
/// 2. **Cold-start seed**: before any ratings exist, estimate a plausible rating
///    from activity signals (how many bags were collected and how deep the
///    discounts are), so new but active stores are not shown as unrated.
enum RatingEstimator {
    /// Neutral-positive prior the weighted rating pulls toward.
    static let priorMean: Double = 4.3
    /// How many ratings it takes for the real average to dominate the prior.
    static let priorWeight: Double = 8

    /// IMDb-style weighted rating.
    /// `WR = (v / (v + m)) * R + (m / (v + m)) * C`
    /// where `v` = count, `R` = average, `m` = prior weight, `C` = prior mean.
    static func weightedRating(average: Double, count: Int) -> Double {
        guard count > 0 else { return priorMean }
        let v = Double(count)
        let m = priorWeight
        return (v / (v + m)) * average + (m / (v + m)) * priorMean
    }

    /// Cold-start estimate for a store that has no ratings yet.
    ///
    /// Starts from a modest base and adds a bounded bonus for popularity
    /// (successful pickups, on a log scale so early orders matter most) and for
    /// generous discounts. Clamped to a believable 3.6...4.9 range.
    static func coldStartEstimate(pickedUpOrders: Int, averageSavingsPercent: Int) -> Double {
        let base = 3.8
        let popularityBonus = min(0.6, log10(Double(max(0, pickedUpOrders)) + 1) * 0.35)
        let savingsBonus = min(0.5, Double(max(0, averageSavingsPercent)) / 100.0 * 0.8)
        let estimate = base + popularityBonus + savingsBonus
        return min(4.9, max(3.6, estimate))
    }
}
