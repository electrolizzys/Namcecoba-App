import SwiftUI
import UIKit

enum DesignTokens {
    static let cornerRadius: CGFloat = 14
    static let smallCornerRadius: CGFloat = 8
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8

    static let cardShadowColor: Color = .black.opacity(0.08)
    static let cardShadowRadius: CGFloat = 8

    // A calmer, more natural leaf-green (the previous emerald read as too neon).
    static let primaryGreen = Color(red: 0.17, green: 0.51, blue: 0.34)
    static let primaryGreenDark = Color(red: 0.10, green: 0.37, blue: 0.24)
    static let accentOrange = Color(red: 0.93, green: 0.55, blue: 0.24)
    static let selectedChipBackground = Color(red: 0.91, green: 0.95, blue: 0.92)

    static let headerGradient = LinearGradient(
        colors: [primaryGreen, primaryGreenDark],
        startPoint: .top,
        endPoint: .bottom
    )

    static let filterControlHeight: CGFloat = 40
    static let chipCornerRadius: CGFloat = 10

    /// Extra scroll length under list/scroll content so the floating glass tab bar does not cover it.
    static let floatingTabBarClearance: CGFloat = 108

    static func configureTabBarAppearance() {
        let apply = {
            // The app ships a fully custom floating "glass" tab bar (see MainTabView).
            // The native UITabBar is hidden on every tab, so make it transparent — an
            // opaque background here paints a thick white strip along the bottom edge.
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            appearance.shadowColor = .clear
            appearance.shadowImage = UIImage()

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

        if Thread.isMainThread {
            apply()
        } else {
            DispatchQueue.main.async(execute: apply)
        }
    }

    static func gradientForCategory(_ category: ProductCategory) -> LinearGradient {
        let colors: [Color] = switch category {
        case .bakery:
            [Color(red: 0.85, green: 0.6, blue: 0.25), Color(red: 0.72, green: 0.42, blue: 0.15)]
        case .restaurant:
            [Color(red: 0.82, green: 0.22, blue: 0.18), Color(red: 0.62, green: 0.14, blue: 0.12)]
        case .grocery:
            [Color(red: 0.22, green: 0.7, blue: 0.38), Color(red: 0.12, green: 0.55, blue: 0.28)]
        case .cafe:
            [Color(red: 0.58, green: 0.38, blue: 0.22), Color(red: 0.42, green: 0.28, blue: 0.18)]
        case .pastry:
            [Color(red: 0.85, green: 0.42, blue: 0.62), Color(red: 0.68, green: 0.28, blue: 0.48)]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct AppCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(DesignTokens.padding)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.cornerRadius))
            .shadow(color: DesignTokens.cardShadowColor, radius: DesignTokens.cardShadowRadius, y: 4)
    }
}

struct AppFilterMenu<Content: View>: View {
    let icon: String
    let label: String
    @ViewBuilder var content: Content

    var body: some View {
        Menu {
            content
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Spacer(minLength: 0)
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.semibold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .clipShape(Capsule())
            .contentShape(Capsule())
            .frame(maxWidth: .infinity)
        }
    }
}

struct AppInlineSearchField: View {
    let placeholder: String
    @Binding var text: String
    var inverted = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline)
                .foregroundStyle(inverted ? .white.opacity(0.85) : .secondary)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.subheadline)
                        .foregroundStyle(inverted ? .white.opacity(0.65) : .secondary)
                        .allowsHitTesting(false)
                }

                TextField("", text: $text)
                    .font(.subheadline)
                    .foregroundStyle(inverted ? .white : .primary)
                    .tint(inverted ? .white : .accentColor)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(inverted ? .white.opacity(0.85) : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: DesignTokens.filterControlHeight)
        .background(
            inverted
                ? Color.white.opacity(0.18)
                : Color(.secondarySystemBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.chipCornerRadius))
    }
}

struct AppInlineSortMenu<Content: View>: View {
    let label: String
    var inverted = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        Menu(content: content) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.subheadline)
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(inverted ? .white : .primary)
            .padding(.horizontal, 14)
            .frame(height: DesignTokens.filterControlHeight)
            .background(
                inverted
                    ? Color.white.opacity(0.18)
                    : Color(.secondarySystemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.chipCornerRadius))
            .contentShape(RoundedRectangle(cornerRadius: DesignTokens.chipCornerRadius))
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct AppFilterChip: View {
    let title: String
    var systemIcon: String?
    var emoji: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let emoji {
                    Text(emoji)
                        .font(.subheadline)
                } else if let systemIcon {
                    Image(systemName: systemIcon)
                        .font(.subheadline)
                }
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.horizontal, 16)
            .frame(height: DesignTokens.filterControlHeight)
            .background(chipBackground)
            .overlay(chipBorder)
            .foregroundStyle(isSelected ? DesignTokens.primaryGreen : .primary)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.chipCornerRadius))
            .contentShape(RoundedRectangle(cornerRadius: DesignTokens.chipCornerRadius))
        }
        .buttonStyle(.plain)
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    private var chipBackground: some View {
        RoundedRectangle(cornerRadius: DesignTokens.chipCornerRadius)
            .fill(
                isSelected
                    ? Color.white
                    : Color.white.opacity(0.72)
            )
    }

    @ViewBuilder
    private var chipBorder: some View {
        RoundedRectangle(cornerRadius: DesignTokens.chipCornerRadius)
            .stroke(
                isSelected
                    ? DesignTokens.primaryGreen
                    : DesignTokens.primaryGreen.opacity(0.2),
                lineWidth: isSelected ? 1.5 : 1
            )
    }
}

struct AppCategoryFilterCarousel: View {
    @Binding var selectedCategory: ProductCategory?

    var body: some View {
        HorizontalOnlyScrollView {
            HStack(spacing: 10) {
                AppFilterChip(
                    title: "All Types",
                    systemIcon: "square.grid.2x2",
                    isSelected: selectedCategory == nil
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = nil
                    }
                }

                ForEach(ProductCategory.allCases) { category in
                    AppFilterChip(
                        title: category.rawValue,
                        emoji: category.icon,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, DesignTokens.padding)
            .fixedSize(horizontal: true, vertical: true)
        }
        .frame(height: DesignTokens.filterControlHeight)
    }
}

/// UIKit-backed horizontal scroller — SwiftUI `ScrollView(.horizontal)` still
/// rubber-bands vertically; this locks movement to the X axis only.
private struct HorizontalOnlyScrollView<Content: View>: UIViewRepresentable {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = false
        scrollView.bounces = true
        scrollView.isDirectionalLockEnabled = true
        scrollView.clipsToBounds = true
        scrollView.backgroundColor = .clear
        scrollView.contentInsetAdjustmentBehavior = .never

        let host = UIHostingController(rootView: content)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .clear
        if #available(iOS 16.4, *) {
            host.safeAreaRegions = []
        }
        scrollView.addSubview(host.view)
        context.coordinator.host = host

        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            // Keep content height equal to the viewport so vertical scrolling is impossible.
            host.view.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.host?.rootView = content
        scrollView.alwaysBounceVertical = false
        scrollView.isDirectionalLockEnabled = true
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        var host: UIHostingController<Content>?

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // Hard lock: never allow a vertical offset, even mid-gesture.
            if scrollView.contentOffset.y != 0 {
                scrollView.contentOffset.y = 0
            }
        }
    }
}

/// Shared green header used across all main tab screens: a search field with an
/// optional trailing control (sort/filter menu) inside a rounded gradient panel,
/// plus an optional filter row (category / type chips) beneath it.
struct AppScreenHeader<Trailing: View, FilterRow: View>: View {
    let searchPlaceholder: String
    @Binding var searchText: String
    @ViewBuilder var trailing: () -> Trailing
    @ViewBuilder var filterRow: () -> FilterRow

    init(
        searchPlaceholder: String,
        searchText: Binding<String>,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() },
        @ViewBuilder filterRow: @escaping () -> FilterRow = { EmptyView() }
    ) {
        self.searchPlaceholder = searchPlaceholder
        self._searchText = searchText
        self.trailing = trailing
        self.filterRow = filterRow
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                AppInlineSearchField(
                    placeholder: searchPlaceholder,
                    text: $searchText,
                    inverted: true
                )
                trailing()
            }
            .padding(.horizontal, DesignTokens.padding)
            .padding(.top, 2)
            .padding(.bottom, 12)
            .background(DesignTokens.headerGradient)
            .clipShape(
                UnevenRoundedRectangle(
                    bottomLeadingRadius: 22,
                    bottomTrailingRadius: 22,
                    style: .continuous
                )
            )
            .shadow(color: DesignTokens.primaryGreen.opacity(0.28), radius: 9, y: 5)
            .zIndex(1)

            filterRow()
        }
        .background(DesignTokens.selectedChipBackground)
    }
}

struct AppListControlsHeader<SortMenuContent: View>: View {
    let searchPlaceholder: String
    @Binding var searchText: String
    let sortLabel: String
    @Binding var selectedCategory: ProductCategory?
    @ViewBuilder var sortMenu: () -> SortMenuContent

    var body: some View {
        AppScreenHeader(searchPlaceholder: searchPlaceholder, searchText: $searchText) {
            AppInlineSortMenu(label: sortLabel, inverted: true, content: sortMenu)
        } filterRow: {
            AppCategoryFilterCarousel(selectedCategory: $selectedCategory)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
        }
    }
}

extension View {
    func brandedListScreenStyle() -> some View {
        background(DesignTokens.selectedChipBackground)
            .toolbarBackground(DesignTokens.primaryGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }

    func appTabBarStyle() -> some View {
        toolbarBackground(.visible, for: .tabBar)
            .toolbarBackground(Color(.systemBackground), for: .tabBar)
    }

    func lightGreenScreenStyle() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DesignTokens.selectedChipBackground)
    }

    /// Appends blank scrollable height under this content so the last items clear the floating tab bar.
    /// Prefer this over padding/safe-area insets on the whole screen — only extends content length.
    func floatingTabBarScrollFiller() -> some View {
        VStack(spacing: 0) {
            self
            FloatingTabBarScrollFiller()
        }
    }

    /// Lifts a sticky bottom bar (e.g. Order) above the floating tab bar.
    func floatingTabBarBottomBarClearance() -> some View {
        padding(.bottom, DesignTokens.floatingTabBarClearance)
    }

    /// Adds the map explore button to the nav bar and its full-screen cover.
    func mapExploreToolbarItem(isPresented: Binding<Bool>) -> some View {
        toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresented.wrappedValue = true
                } label: {
                    Image(systemName: "map.fill")
                        .foregroundStyle(.white)
                }
            }
        }
        .fullScreenCover(isPresented: isPresented) {
            MapExploreView()
        }
    }
}

/// Transparent trailing space; page background shows through when scrolling past the last item.
struct FloatingTabBarScrollFiller: View {
    var body: some View {
        Color.clear
            .frame(height: DesignTokens.floatingTabBarClearance)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }
}

enum FloatingTabBarListFiller {
    /// Last section in a `List` — adds scrollable blank height without shrinking the list viewport.
    @ViewBuilder
    static var section: some View {
        Section {
            FloatingTabBarScrollFiller()
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
    }
}

struct AppEmptyState: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}
