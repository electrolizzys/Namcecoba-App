import SwiftUI

/// Segmented period selector used across the analytics screens.
struct AnalyticsPeriodPicker: View {
    @Binding var selection: AnalyticsPeriod

    var body: some View {
        Picker("Period", selection: $selection) {
            ForEach(AnalyticsPeriod.allCases) { period in
                Text(period.displayName).tag(period)
            }
        }
        .pickerStyle(.segmented)
    }
}

/// A large highlighted metric shown at the top of an analytics screen.
struct AnalyticsHeroCard: View {
    let title: String
    let value: String
    let caption: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))

            Text(value)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text(caption)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(DesignTokens.headerGradient)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .shadow(color: DesignTokens.primaryGreen.opacity(0.28), radius: 10, y: 6)
    }
}

/// A compact metric tile for the analytics grid.
struct AnalyticsStatCard: View {
    let title: String
    let value: String
    let systemImage: String
    var tint: Color = DesignTokens.primaryGreen

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 9))

            Text(value)
                .font(.title3.bold())
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .shadow(color: DesignTokens.cardShadowColor, radius: 6, y: 3)
    }
}

/// A two-column grid wrapper for `AnalyticsStatCard`s.
struct AnalyticsStatGrid<Content: View>: View {
    @ViewBuilder var content: Content

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            content
        }
    }
}

/// A titled card that groups a set of labelled rows.
struct AnalyticsSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
        .shadow(color: DesignTokens.cardShadowColor, radius: 6, y: 3)
    }
}

/// A single label/value row used inside `AnalyticsSectionCard`.
struct AnalyticsRow: View {
    let title: String
    let value: String
    var tint: Color = .primary

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(tint)
        }
        .font(.subheadline)
    }
}
