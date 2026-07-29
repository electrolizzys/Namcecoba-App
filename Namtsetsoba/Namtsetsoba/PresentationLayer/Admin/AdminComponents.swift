import SwiftUI

extension SalesPeriod {
    /// Localized, user-facing period name.
    var localizedName: String {
        switch self {
        case .lastMonth: L(.periodLastMonth)
        case .lastQuarter: L(.periodLastQuarter)
        case .lastYear: L(.periodLastYear)
        }
    }
}

/// Shared visual language for admin screens: KPI cards, section cards, rows, pills.
enum AdminPalette {
    static let green = DesignTokens.primaryGreen
    static let orange = DesignTokens.accentOrange
    static let blue = Color(red: 0.23, green: 0.51, blue: 0.96)
    static let red = Color(red: 0.90, green: 0.30, blue: 0.30)
    static let purple = Color(red: 0.56, green: 0.40, blue: 0.86)
    static let teal = Color(red: 0.16, green: 0.62, blue: 0.63)
}

/// A compact KPI tile (icon chip, big value, caption).
struct AdminStatCard: View {
    let icon: String
    let title: String
    let value: String
    var tint: Color = AdminPalette.green
    var showsChevron: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 34, height: 34)
                    .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                Spacer()
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.tertiary)
                }
            }
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

/// Equal-width branded period selector for admin analytics screens.
struct AdminPeriodPicker: View {
    @Binding var selection: SalesPeriod

    var body: some View {
        HStack(spacing: 6) {
            ForEach(SalesPeriod.allCases) { period in
                let isSelected = selection == period
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        selection = period
                    }
                } label: {
                    Text(period.localizedName)
                        .font(.caption.weight(isSelected ? .bold : .semibold))
                        .foregroundStyle(isSelected ? DesignTokens.primaryGreen : .secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.75)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 4)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground).opacity(0.9))
        )
        .accessibilityLabel(L(.commonPeriod))
    }
}

/// A titled white card used to group rows.
struct AdminSectionCard<Content: View>: View {
    let title: String
    var icon: String?
    @ViewBuilder var content: Content

    init(title: String, icon: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon).foregroundStyle(AdminPalette.green)
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

struct AdminMetricRow: View {
    let title: String
    let value: String
    var tint: Color = .primary

    var body: some View {
        HStack {
            Text(title).font(.subheadline)
            Spacer()
            Text(value).font(.subheadline.weight(.semibold)).foregroundStyle(tint)
        }
    }
}

struct AdminStatusPill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.14), in: Capsule())
    }
}

/// A white rounded card used for list items.
struct AdminRowCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}

extension View {
    /// Styles a `List` row so it reads as a free-standing card on the green background.
    func adminCardRow() -> some View {
        listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
    }
}
