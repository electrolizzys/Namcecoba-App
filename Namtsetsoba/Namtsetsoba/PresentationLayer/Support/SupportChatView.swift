import SwiftUI

/// Two-way support chat thread.
/// - Customer/venue: `conversationId == nil` → their own thread (created on first send).
/// - Admin: pass the conversation id from the inbox.
struct SupportChatView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: SupportChatViewModel
    @State private var pollTask: Task<Void, Never>?

    init(conversationId: UUID? = nil, currentUserId: UUID?) {
        _viewModel = State(
            initialValue: SupportChatViewModel(
                conversationId: conversationId,
                currentUserId: currentUserId
            )
        )
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            messagesList
            composer
        }
        .background(DesignTokens.selectedChipBackground)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
            let conversationId = viewModel.conversation?.id ?? viewModel.fixedConversationIdForRead
            await appState.markSupportConversationNotificationsRead(conversationId: conversationId)
            startPolling()
        }
        .onDisappear {
            pollTask?.cancel()
            pollTask = nil
        }
        .refreshable { await viewModel.load() }
    }

    private var navigationTitle: String {
        if viewModel.isMine {
            return L(.supportChatTitle)
        }
        return viewModel.conversation?.userDisplayName ?? L(.supportChatTitle)
    }

    private var messagesList: some View {
        Group {
            if viewModel.isLoading && viewModel.messages.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.messages.isEmpty {
                AppEmptyState(
                    icon: "bubble.left.and.bubble.right",
                    title: L(.supportChatEmptyTitle),
                    message: L(.supportChatEmptyMessage)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.messages) { message in
                                messageBubble(message)
                                    .id(message.id)
                            }
                        }
                        .padding(DesignTokens.padding)
                        .padding(.bottom, 8)
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        if let last = viewModel.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }

    private func messageBubble(_ message: SupportMessage) -> some View {
        let mine = viewModel.isFromCurrentUser(message)
        return HStack {
            if mine { Spacer(minLength: 48) }
            VStack(alignment: mine ? .trailing : .leading, spacing: 4) {
                Text(message.body)
                    .font(.body)
                    .foregroundStyle(mine ? Color.white : Color.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        mine
                            ? AnyShapeStyle(DesignTokens.primaryGreen)
                            : AnyShapeStyle(Color(.systemBackground)),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                Text(Self.timeString(message.createdAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            if !mine { Spacer(minLength: 48) }
        }
    }

    private var composer: some View {
        VStack(spacing: 0) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DesignTokens.padding)
                    .padding(.top, 8)
            }

            HStack(alignment: .bottom, spacing: 10) {
                TextField(L(.supportChatPlaceholder), text: $viewModel.draft, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(12)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Button {
                    Task { await viewModel.send() }
                } label: {
                    Group {
                        if viewModel.isSending {
                            ProgressView().tint(.white)
                        } else {
                            Image(systemName: "paperplane.fill")
                        }
                    }
                    .frame(width: 44, height: 44)
                    .foregroundStyle(.white)
                    .background(DesignTokens.primaryGreen, in: Circle())
                }
                .disabled(viewModel.isSending || viewModel.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, DesignTokens.padding)
            .padding(.top, 10)
            .padding(.bottom, 14)
            .background(.ultraThinMaterial)
            // Sit just above the floating glass tab bar (less than list scroll clearance).
            .padding(.bottom, 76)
        }
    }

    private func startPolling() {
        pollTask?.cancel()
        pollTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(4))
                guard !Task.isCancelled else { return }
                await viewModel.load()
            }
        }
    }

    private static func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = Calendar.current.isDateInToday(date) ? .none : .short
        return formatter.string(from: date)
    }
}

// MARK: - Admin inbox

struct AdminSupportInboxView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = AdminSupportInboxViewModel()
    @State private var showStartChat = false
    @State private var openedConversationId: UUID?

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.conversations.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.conversations.isEmpty {
                VStack(spacing: 16) {
                    AppEmptyState(
                        icon: "lifepreserver",
                        title: L(.supportInboxEmptyTitle),
                        message: L(.supportInboxEmptyMessage)
                    )
                    Button {
                        showStartChat = true
                    } label: {
                        Label(L(.supportStartChat), systemImage: "square.and.pencil")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(DesignTokens.primaryGreen, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.conversations) { conversation in
                        NavigationLink {
                            SupportChatView(
                                conversationId: conversation.id,
                                currentUserId: appState.userId
                            )
                        } label: {
                            conversationRow(conversation)
                        }
                    }

                    FloatingTabBarListFiller.section
                }
                .scrollContentBackground(.hidden)
            }
        }
        .background(DesignTokens.selectedChipBackground)
        .navigationTitle(L(.supportInboxTitle))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showStartChat = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .accessibilityLabel(L(.supportStartChat))
            }
        }
        .navigationDestination(item: $openedConversationId) { conversationId in
            SupportChatView(conversationId: conversationId, currentUserId: appState.userId)
        }
        .sheet(isPresented: $showStartChat) {
            AdminStartSupportChatView { conversationId in
                showStartChat = false
                Task {
                    await viewModel.load()
                    openedConversationId = conversationId
                }
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private func conversationRow(_ conversation: SupportConversation) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(conversation.userDisplayName)
                    .font(.headline)
                Spacer()
                if let at = conversation.lastMessageAt {
                    Text(relativeTime(at))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Text(roleLabel(conversation.userRole) + " · " + conversation.userEmail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            if let preview = conversation.lastMessagePreview, !preview.isEmpty {
                Text(preview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }

    private func roleLabel(_ role: String) -> String {
        switch role {
        case "venue": return L(.supportRoleVenue)
        case "admin": return L(.supportRoleAdmin)
        default: return L(.supportRoleCustomer)
        }
    }

    private func relativeTime(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return L(.alertsJustNow) }
        if interval < 3600 { return String(format: L(.alertsMinutesAgo), Int(interval / 60)) }
        if interval < 86400 { return String(format: L(.alertsHoursAgo), Int(interval / 3600)) }
        return String(format: L(.alertsDaysAgo), Int(interval / 86400))
    }
}

/// Admin picks a customer or venue and opens (or creates) their support thread.
struct AdminStartSupportChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var usersViewModel = AdminUsersViewModel()
    @State private var inboxViewModel = AdminSupportInboxViewModel()
    @State private var isOpening = false
    let onOpened: (UUID) -> Void

    private var eligibleUsers: [UserProfile] {
        usersViewModel.filteredUsers.filter { $0.role != .admin }
    }

    private var errorMessage: String? {
        inboxViewModel.errorMessage ?? usersViewModel.errorMessage
    }

    var body: some View {
        NavigationStack {
            List {
                if usersViewModel.isLoading && eligibleUsers.isEmpty {
                    ProgressView().adminCardRow()
                } else if eligibleUsers.isEmpty {
                    Text(L(.supportStartChatEmpty))
                        .foregroundStyle(.secondary)
                        .adminCardRow()
                } else {
                    ForEach(eligibleUsers, id: \.id) { user in
                        Button {
                            Task { await openChat(with: user) }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: user.role == .business ? "storefront.fill" : "person.fill")
                                    .foregroundStyle(DesignTokens.primaryGreen)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(user.username.isEmpty ? user.email : user.username)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(user.email)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(user.role == .business ? L(.supportRoleVenue) : L(.supportRoleCustomer))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .disabled(isOpening)
                        .adminCardRow()
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .adminCardRow()
                }
            }
            .scrollContentBackground(.hidden)
            .background(DesignTokens.selectedChipBackground)
            .navigationTitle(L(.supportStartChat))
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $usersViewModel.searchText, prompt: L(.adminSearchUsers))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L(.commonCancel)) { dismiss() }
                }
            }
            .overlay {
                if isOpening {
                    ProgressView()
                        .padding(20)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .task { await usersViewModel.load() }
        }
    }

    @MainActor
    private func openChat(with user: UserProfile) async {
        isOpening = true
        defer { isOpening = false }
        if let id = await inboxViewModel.openChat(forUserId: user.id) {
            onOpened(id)
        }
    }
}
