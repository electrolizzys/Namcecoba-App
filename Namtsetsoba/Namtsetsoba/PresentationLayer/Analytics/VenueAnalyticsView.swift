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
                    title: L(.venueYourIncome),
                    value: Utilities.formatMoneyGel(viewModel.analytics.storeIncome),
                    caption: String(format: L(.venueIncomeCaption), Self.commissionPercent, viewModel.period.localizedName),
                    systemImage: "banknote.fill"
                )

                AnalyticsStatGrid {
                    AnalyticsStatCard(
                        title: L(.venueBagsSold),
                        value: "\(viewModel.analytics.pickedUpCount)",
                        systemImage: "bag.fill.badge.checkmark"
                    )
                    AnalyticsStatCard(
                        title: L(.venueActiveOrders),
                        value: "\(viewModel.analytics.activeOrderCount)",
                        systemImage: "clock.badge.fill",
                        tint: Color(red: 0.23, green: 0.51, blue: 0.96)
                    )
                    AnalyticsStatCard(
                        title: L(.venueAvgOrderValue),
                        value: Utilities.formatMoneyGel(viewModel.analytics.averageOrderValue),
                        systemImage: "cart.fill",
                        tint: DesignTokens.accentOrange
                    )
                    AnalyticsStatCard(
                        title: L(.venuePickupRate),
                        value: percent(viewModel.analytics.pickupRate),
                        systemImage: "checkmark.seal.fill"
                    )
                }

                AnalyticsSectionCard(title: L(.venueRevenueBreakdown)) {
                    AnalyticsRow(
                        title: L(.venueGrossRevenue),
                        value: Utilities.formatMoneyGel(viewModel.analytics.grossRevenue)
                    )
                    AnalyticsRow(
                        title: String(format: L(.venuePlatformFee), Self.commissionPercent),
                        value: "-\(Utilities.formatMoneyGel(viewModel.analytics.platformFee))",
                        tint: .red
                    )
                    Divider()
                    AnalyticsRow(
                        title: L(.venueYourIncome),
                        value: Utilities.formatMoneyGel(viewModel.analytics.storeIncome),
                        tint: DesignTokens.primaryGreen
                    )
                }

                AnalyticsSectionCard(title: L(.venueOrders)) {
                    AnalyticsRow(title: L(.venuePickedUp), value: "\(viewModel.analytics.pickedUpCount)")
                    AnalyticsRow(title: L(.venueCancelled), value: "\(viewModel.analytics.cancelledCount)")
                    AnalyticsRow(title: L(.venueAwaitingPickup), value: "\(viewModel.analytics.activeOrderCount)")
                }

                AnalyticsSectionCard(title: L(.venueCustomers)) {
                    AnalyticsRow(title: L(.venueUniqueCustomers), value: "\(viewModel.analytics.uniqueCustomers)")
                    AnalyticsRow(title: L(.venueRepeatCustomers), value: percent(viewModel.analytics.repeatCustomerRate))
                }

                ratingCard(viewModel.analytics)

                impactCard(viewModel.analytics)
            }
            .padding(DesignTokens.padding)
            .padding(.bottom, DesignTokens.floatingTabBarClearance)
        }
        .background(DesignTokens.selectedChipBackground)
        .navigationTitle(L(.profileVenueAnalytics))
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

        return AnalyticsSectionCard(title: L(.venueCustomerRating)) {
            HStack(spacing: 10) {
                Image(systemName: "star.fill")
                    .font(.title)
                    .foregroundStyle(DesignTokens.accentOrange)
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.title2.bold())
                    Text(hasRatings
                         ? String(format: L(.venueRatingsCount), store.ratingCount)
                         : L(.venueEstimatedNoRatings))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }

    private func impactCard(_ analytics: VenueAnalytics) -> some View {
        AnalyticsSectionCard(title: L(.venueImpactCreated)) {
            AnalyticsRow(title: L(.venueMealsRescued), value: "\(analytics.mealsSaved)")
            AnalyticsRow(
                title: L(.venueCustomerSavings),
                value: Utilities.formatMoneyGel(analytics.customerSavings),
                tint: DesignTokens.primaryGreen
            )
            AnalyticsRow(
                title: L(.analyticsCO2Avoided),
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
