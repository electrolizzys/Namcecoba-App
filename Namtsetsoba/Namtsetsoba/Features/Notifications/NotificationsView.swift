import SwiftUI

struct NotificationsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.mainTabSelection) private var mainTabSelection

    var body: some View {
        NavigationStack {
            Group {
                if appState.notifications.isEmpty {
                    emptyState
                } else {
                    notificationList
                }
            }
            .brandedListScreenStyle()
            .navigationTitle("Notifications")
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
        List {
            ForEach(appState.notifications) { notification in
                NotificationRow(notification: notification)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: DesignTokens.chipCornerRadius)
                            .fill(Color(.systemBackground))
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .onTapGesture {
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
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            AppEmptyState(
                icon: "bell.slash",
                title: "No notifications yet",
                message: "You'll see orders and favorite-store offers here"
            )
            Spacer()
        }
        .padding()
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
        .padding(.vertical, 4)
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

#Preview {
    NotificationsView()
        .environment(AppState())
}
