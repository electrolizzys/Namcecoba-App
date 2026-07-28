import SwiftUI

/// Personal activity and environmental-impact summary for a customer.
struct CustomerAnalyticsView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = CustomerAnalyticsViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(spacing: 16) {
                AnalyticsPeriodPicker(selection: $viewModel.period)

                AnalyticsHeroCard(
                    title: L(.analyticsMoneySaved),
                    value: Utilities.formatMoneyGel(viewModel.analytics.moneySaved),
                    caption: String(format: L(.analyticsMoneySavedCaption), viewModel.analytics.bagsRescued, viewModel.period.localizedName),
                    systemImage: "sparkles"
                )

                AnalyticsStatGrid {
                    AnalyticsStatCard(
                        title: L(.analyticsOrdersPlaced),
                        value: "\(viewModel.analytics.ordersPlaced)",
                        systemImage: "bag.fill"
                    )
                    AnalyticsStatCard(
                        title: L(.analyticsBagsRescued),
                        value: "\(viewModel.analytics.bagsRescued)",
                        systemImage: "leaf.fill"
                    )
                    AnalyticsStatCard(
                        title: L(.analyticsTotalSpent),
                        value: Utilities.formatMoneyGel(viewModel.analytics.totalSpent),
                        systemImage: "creditcard.fill",
                        tint: Color(red: 0.23, green: 0.51, blue: 0.96)
                    )
                    AnalyticsStatCard(
                        title: L(.analyticsAvgDiscount),
                        value: "\(viewModel.analytics.averageSavingsPercent)%",
                        systemImage: "tag.fill",
                        tint: DesignTokens.accentOrange
                    )
                }

                impactCard(viewModel.analytics)

                if let favourite = viewModel.analytics.favouriteStoreName {
                    AnalyticsSectionCard(title: L(.analyticsMostVisited)) {
                        AnalyticsRow(title: L(.analyticsFavouriteStore), value: favourite)
                    }
                }
            }
            .padding(DesignTokens.padding)
            .floatingTabBarScrollFiller()
        }
        .background(DesignTokens.selectedChipBackground)
        .navigationTitle(L(.analyticsYourImpact))
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isLoading && viewModel.analytics.ordersPlaced == 0 {
                ProgressView()
            }
        }
        .task { await load() }
        .refreshable { await load() }
    }

    private func impactCard(_ analytics: CustomerAnalytics) -> some View {
        AnalyticsSectionCard(title: L(.analyticsGreenImpact)) {
            AnalyticsRow(
                title: L(.analyticsCO2Avoided),
                value: String(format: "%.1f kg", analytics.co2SavedKg),
                tint: DesignTokens.primaryGreen
            )
            AnalyticsRow(
                title: L(.analyticsMealsKept),
                value: "\(analytics.bagsRescued)",
                tint: DesignTokens.primaryGreen
            )
        }
    }

    @MainActor
    private func load() async {
        guard let userId = appState.userId else { return }
        await viewModel.load(userId: userId)
    }
}
