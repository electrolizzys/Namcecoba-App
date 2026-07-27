import SwiftUI

/// Sales and impact dashboard for a venue account.
struct VenueAnalyticsView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = VenueAnalyticsViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(spacing: 16) {
                AnalyticsPeriodPicker(selection: $viewModel.period)

                AnalyticsHeroCard(
                    title: "Your income",
                    value: Utilities.formatMoneyGel(viewModel.analytics.storeIncome),
                    caption: "After \(Self.commissionPercent) platform fee · \(viewModel.period.displayName.lowercased())",
                    systemImage: "banknote.fill"
                )

                AnalyticsStatGrid {
                    AnalyticsStatCard(
                        title: "Bags sold",
                        value: "\(viewModel.analytics.pickedUpCount)",
                        systemImage: "bag.fill.badge.checkmark"
                    )
                    AnalyticsStatCard(
                        title: "Active orders",
                        value: "\(viewModel.analytics.activeOrderCount)",
                        systemImage: "clock.badge.fill",
                        tint: Color(red: 0.23, green: 0.51, blue: 0.96)
                    )
                    AnalyticsStatCard(
                        title: "Avg. order value",
                        value: Utilities.formatMoneyGel(viewModel.analytics.averageOrderValue),
                        systemImage: "cart.fill",
                        tint: DesignTokens.accentOrange
                    )
                    AnalyticsStatCard(
                        title: "Pickup rate",
                        value: percent(viewModel.analytics.pickupRate),
                        systemImage: "checkmark.seal.fill"
                    )
                }

                AnalyticsSectionCard(title: "Revenue breakdown") {
                    AnalyticsRow(
                        title: "Gross revenue",
                        value: Utilities.formatMoneyGel(viewModel.analytics.grossRevenue)
                    )
                    AnalyticsRow(
                        title: "Platform fee (\(Self.commissionPercent))",
                        value: "-\(Utilities.formatMoneyGel(viewModel.analytics.platformFee))",
                        tint: .red
                    )
                    Divider()
                    AnalyticsRow(
                        title: "Your income",
                        value: Utilities.formatMoneyGel(viewModel.analytics.storeIncome),
                        tint: DesignTokens.primaryGreen
                    )
                }

                AnalyticsSectionCard(title: "Orders") {
                    AnalyticsRow(title: "Picked up", value: "\(viewModel.analytics.pickedUpCount)")
                    AnalyticsRow(title: "Cancelled", value: "\(viewModel.analytics.cancelledCount)")
                    AnalyticsRow(title: "Awaiting pickup now", value: "\(viewModel.analytics.activeOrderCount)")
                }

                AnalyticsSectionCard(title: "Customers") {
                    AnalyticsRow(title: "Unique customers", value: "\(viewModel.analytics.uniqueCustomers)")
                    AnalyticsRow(title: "Repeat customers", value: percent(viewModel.analytics.repeatCustomerRate))
                }

                ratingCard(viewModel.analytics)

                impactCard(viewModel.analytics)
            }
            .padding(DesignTokens.padding)
        }
        .background(DesignTokens.selectedChipBackground)
        .navigationTitle("Sales & Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isLoading && viewModel.analytics.pickedUpCount == 0 {
                ProgressView()
            }
        }
        .task { await viewModel.load(storeId: appState.businessStore.id) }
        .refreshable { await viewModel.load(storeId: appState.businessStore.id) }
    }

    private func ratingCard(_ analytics: VenueAnalytics) -> some View {
        let store = appState.businessStore
        let hasRatings = store.ratingCount > 0
        let value = hasRatings
            ? store.displayRatingText
            : String(format: "%.1f", RatingEstimator.coldStartEstimate(
                pickedUpOrders: analytics.pickedUpCount,
                averageSavingsPercent: analytics.averageSavingsPercent
            ))

        return AnalyticsSectionCard(title: "Customer rating") {
            HStack(spacing: 10) {
                Image(systemName: "star.fill")
                    .font(.title)
                    .foregroundStyle(DesignTokens.accentOrange)
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.title2.bold())
                    Text(hasRatings
                         ? "\(store.ratingCount) customer rating\(store.ratingCount == 1 ? "" : "s")"
                         : "Estimated · no ratings yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }

    private func impactCard(_ analytics: VenueAnalytics) -> some View {
        AnalyticsSectionCard(title: "Impact you created") {
            AnalyticsRow(title: "Meals rescued", value: "\(analytics.mealsSaved)")
            AnalyticsRow(
                title: "Customer savings",
                value: Utilities.formatMoneyGel(analytics.customerSavings),
                tint: DesignTokens.primaryGreen
            )
            AnalyticsRow(
                title: "CO₂ avoided",
                value: String(format: "%.1f kg", analytics.co2SavedKg),
                tint: DesignTokens.primaryGreen
            )
        }
    }

    private func percent(_ value: Double) -> String {
        String(format: "%.0f%%", value * 100)
    }

    private static let commissionPercent = "\(Int((PlatformEconomics.commissionRate as NSDecimalNumber).doubleValue * 100))%"
}
