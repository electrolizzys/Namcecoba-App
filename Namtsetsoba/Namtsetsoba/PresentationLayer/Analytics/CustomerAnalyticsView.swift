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
                    title: "Money saved",
                    value: Utilities.formatMoneyGel(viewModel.analytics.moneySaved),
                    caption: "Across \(viewModel.analytics.bagsRescued) rescued bag\(viewModel.analytics.bagsRescued == 1 ? "" : "s") · \(viewModel.period.displayName.lowercased())",
                    systemImage: "sparkles"
                )

                AnalyticsStatGrid {
                    AnalyticsStatCard(
                        title: "Orders placed",
                        value: "\(viewModel.analytics.ordersPlaced)",
                        systemImage: "bag.fill"
                    )
                    AnalyticsStatCard(
                        title: "Bags rescued",
                        value: "\(viewModel.analytics.bagsRescued)",
                        systemImage: "leaf.fill"
                    )
                    AnalyticsStatCard(
                        title: "Total spent",
                        value: Utilities.formatMoneyGel(viewModel.analytics.totalSpent),
                        systemImage: "creditcard.fill",
                        tint: Color(red: 0.23, green: 0.51, blue: 0.96)
                    )
                    AnalyticsStatCard(
                        title: "Avg. discount",
                        value: "\(viewModel.analytics.averageSavingsPercent)%",
                        systemImage: "tag.fill",
                        tint: DesignTokens.accentOrange
                    )
                }

                impactCard(viewModel.analytics)

                if let favourite = viewModel.analytics.favouriteStoreName {
                    AnalyticsSectionCard(title: "Most visited") {
                        AnalyticsRow(title: "Favourite store", value: favourite)
                    }
                }
            }
            .padding(DesignTokens.padding)
        }
        .background(DesignTokens.selectedChipBackground)
        .navigationTitle("Your Impact")
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
        AnalyticsSectionCard(title: "Your green impact") {
            AnalyticsRow(
                title: "CO₂ avoided",
                value: String(format: "%.1f kg", analytics.co2SavedKg),
                tint: DesignTokens.primaryGreen
            )
            AnalyticsRow(
                title: "Meals kept out of waste",
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
