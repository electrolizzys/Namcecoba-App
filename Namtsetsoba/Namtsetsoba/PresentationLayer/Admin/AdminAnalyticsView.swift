import SwiftUI

struct AdminAnalyticsView: View {
    @State private var viewModel = AdminAnalyticsViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        @Bindable var viewModel = viewModel

        ScrollView {
            VStack(spacing: 16) {
                Picker("Period", selection: $viewModel.period) {
                    ForEach(SalesPeriod.allCases) { period in
                        Text(period.localizedName).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.period) { _, _ in
                    Task { await viewModel.load() }
                }

                if viewModel.isLoading && viewModel.snapshot == nil {
                    ProgressView().padding(.top, 40)
                } else if let snapshot = viewModel.snapshot {
                    LazyVGrid(columns: columns, spacing: 12) {
                        AdminStatCard(icon: "xmark.bin.fill", title: L(.adminCancelRate),
                                      value: String(format: "%.0f%%", snapshot.cancelRate * 100),
                                      tint: snapshot.cancelRate > 0.2 ? AdminPalette.red : AdminPalette.blue)
                        AdminStatCard(icon: "arrow.triangle.2.circlepath", title: L(.venueRepeatCustomers),
                                      value: String(format: "%.0f%%", snapshot.repeatCustomerRate * 100),
                                      tint: AdminPalette.purple)
                        AdminStatCard(icon: "creditcard.fill", title: L(.adminAvgOrderValue),
                                      value: Utilities.formatMoneyGel(snapshot.averageOrderValue),
                                      tint: AdminPalette.green)
                        AdminStatCard(icon: "person.2.fill", title: L(.adminRepeat2plus),
                                      value: "≥2", tint: AdminPalette.teal)
                    }

                    AdminSectionCard(title: L(.adminOrderStatusBreakdown), icon: "chart.bar.fill") {
                        ForEach(Array(OrderStatus.allCases.enumerated()), id: \.element) { index, status in
                            if index > 0 { Divider() }
                            AdminMetricRow(
                                title: status.localizedName,
                                value: "\(snapshot.statusCounts[status] ?? 0)",
                                tint: status.color
                            )
                        }
                    }
                }

                if let error = viewModel.errorMessage {
                    Text(error).foregroundStyle(.red).font(.caption)
                }
            }
            .padding(16)
            .padding(.bottom, DesignTokens.floatingTabBarClearance)
        }
        .background(DesignTokens.selectedChipBackground)
        .navigationTitle(L(.adminStatistics))
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}
