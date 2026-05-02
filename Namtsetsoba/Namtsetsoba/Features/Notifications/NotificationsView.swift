import SwiftUI

struct NotificationsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            Group {
                if appState.notifications.isEmpty {
                    emptyState
                } else {
                    notificationList
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                if appState.unreadCount > 0 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Read All") {
                            Task { await appState.markAllNotificationsRead() }
                        }
                        .font(.subheadline)
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
                    .listRowBackground(notification.isRead ? Color.clear : DesignTokens.primaryGreen.opacity(0.05))
                    .onTapGesture {
                        if !notification.isRead {
                            Task { await appState.markNotificationRead(notification) }
                        }
                    }
            }
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No notifications yet")
                .font(.headline)
            Text("You'll see orders and favorite-store offers here")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
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
