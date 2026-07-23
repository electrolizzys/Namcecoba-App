import SwiftUI

struct NotificationsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.mainTabSelection) private var mainTabSelection
    @State private var selectedType: NotificationType?
    @State private var showMap = false

    private var filteredNotifications: [AppNotification] {
        appState.notifications.filter { selectedType == nil || $0.type == selectedType }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NotificationFilterBar(selectedType: $selectedType)
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

                Group {
                    if filteredNotifications.isEmpty {
                        emptyState
                    } else {
                        notificationList
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .brandedListScreenStyle()
            .navigationTitle("Notifications")
            .mapExploreToolbarItem(isPresented: $showMap)
            .toolbar {
                if appState.unreadCount > 0 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Read All") {
                            Task { await appState.markAllNotificationsRead() }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    }
                }
            }
            .refreshable {
                await appState.loadNotifications()
            }
            .task {
                await appState.loadNotifications()
            }
        }
    }

    private var notificationList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(filteredNotifications) { notification in
                    NotificationCard(notification: notification)
                        .onTapGesture { handleTap(notification) }
                }
            }
            .padding(.horizontal, DesignTokens.padding)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
    }

    private func handleTap(_ notification: AppNotification) {
        Task {
            if !notification.isRead {
                await appState.markNotificationRead(notification)
            }

            guard notification.type == .order,
                  let orderId = notification.referenceId else { return }

            await appState.queueOrderNavigation(to: orderId)
            mainTabSelection?.openOrders(isBusiness: appState.currentRole == .business)
        }
    }

    private var emptyState: some View {
        let isFiltering = selectedType != nil
        return VStack(spacing: 16) {
            AppEmptyState(
                icon: isFiltering ? "line.3.horizontal.decrease.circle" : "bell.slash",
                title: isFiltering ? "No matching notifications" : "No notifications yet",
                message: isFiltering
                    ? "Try a different filter"
                    : "You'll see orders and favorite-store offers here"
            )
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Filter Bar

/// Full-width segmented filter shown inside the green header panel.
struct NotificationFilterBar: View {
    @Binding var selectedType: NotificationType?

    private struct Segment: Identifiable {
        let id: String
        let type: NotificationType?
        let title: String
        let icon: String
    }

    private var segments: [Segment] {
        [
            Segment(id: "all", type: nil, title: "All", icon: "square.grid.2x2"),
            Segment(id: "order", type: .order, title: NotificationType.order.filterTitle, icon: NotificationType.order.filterIcon),
            Segment(id: "favourite", type: .favourite, title: NotificationType.favourite.filterTitle, icon: NotificationType.favourite.filterIcon),
        ]
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(segments) { segment in
                segmentButton(segment)
            }
        }
    }

    private func segmentButton(_ segment: Segment) -> some View {
        let isSelected = selectedType == segment.type
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedType = segment.type }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: segment.icon)
                    .font(.caption.weight(.semibold))
                Text(segment.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .frame(height: DesignTokens.filterControlHeight)
            .background(isSelected ? Color.white : Color.white.opacity(0.18))
            .foregroundStyle(isSelected ? DesignTokens.primaryGreen : Color.white)
            .clipShape(Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Notification Card

struct NotificationCard: View {
    let notification: AppNotification

    var body: some View {
        NotificationRow(notification: notification)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        notification.isRead
                            ? Color(.systemBackground)
                            : DesignTokens.primaryGreen.opacity(0.06)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        notification.isRead
                            ? Color.black.opacity(0.06)
                            : DesignTokens.primaryGreen.opacity(0.35),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            notificationIcon

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.subheadline.weight(notification.isRead ? .regular : .semibold))
                    Spacer()
                    Text(notification.timeAgo)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Text(notification.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if !notification.isRead {
                Circle()
                    .fill(DesignTokens.primaryGreen)
                    .frame(width: 8, height: 8)
            }
        }
    }

    @ViewBuilder
    private var notificationIcon: some View {
        if notification.isCancelledOrderNotification {
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 40, height: 40)
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }
        } else if notification.type == .favourite {
            ZStack {
                Circle()
                    .fill(DesignTokens.primaryGreen.opacity(0.18))
                    .frame(width: 40, height: 40)
                Image(systemName: "basket.fill")
                    .font(.body)
                    .foregroundStyle(DesignTokens.primaryGreen)
            }
        } else {
            ZStack {
                Circle()
                    .fill(notification.iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: notification.systemImage)
                    .foregroundStyle(notification.iconColor)
                    .font(.subheadline)
            }
        }
    }
}
