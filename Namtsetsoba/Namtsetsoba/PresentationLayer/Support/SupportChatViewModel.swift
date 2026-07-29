import Foundation
import Observation

@Observable
final class SupportChatViewModel {
    var messages: [SupportMessage] = []
    var conversation: SupportConversation?
    var draft = ""
    var isLoading = false
    var isSending = false
    var errorMessage: String?

    /// When set, this is an admin viewing someone else's thread.
    private let fixedConversationId: UUID?
    private let currentUserId: UUID?

    /// Exposed so the view can mark matching support alerts as read.
    var fixedConversationIdForRead: UUID? { fixedConversationId }

    @ObservationIgnored private let fetchConversation: FetchSupportConversationUseCase
    @ObservationIgnored private let fetchMyConversation: FetchMySupportConversationUseCase
    @ObservationIgnored private let fetchMessages: FetchSupportMessagesUseCase
    @ObservationIgnored private let sendMessage: SendSupportChatMessageUseCase

    init(
        conversationId: UUID? = nil,
        currentUserId: UUID?,
        container: AppContainer = .shared
    ) {
        self.fixedConversationId = conversationId
        self.currentUserId = currentUserId
        fetchConversation = container.fetchSupportConversation
        fetchMyConversation = container.fetchMySupportConversation
        fetchMessages = container.fetchSupportMessages
        sendMessage = container.sendSupportChatMessage
    }

    var isMine: Bool { fixedConversationId == nil }

    func isFromCurrentUser(_ message: SupportMessage) -> Bool {
        guard let currentUserId else { return false }
        return message.senderId == currentUserId
    }

    @MainActor
    func load() async {
        isLoading = messages.isEmpty
        errorMessage = nil
        do {
            if let fixedConversationId {
                conversation = try await fetchConversation.execute(id: fixedConversationId)
            } else {
                conversation = try await fetchMyConversation.execute()
            }
            if let id = conversation?.id ?? fixedConversationId {
                messages = try await fetchMessages.execute(conversationId: id)
            } else {
                messages = []
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    @MainActor
    func send() async {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isSending = true
        errorMessage = nil
        do {
            let convoId = fixedConversationId ?? conversation?.id
            try await sendMessage.execute(body: trimmed, conversationId: convoId)
            draft = ""
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSending = false
    }
}

@Observable
final class AdminSupportInboxViewModel {
    var conversations: [SupportConversation] = []
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored private let fetchConversations: FetchSupportConversationsUseCase

    init(container: AppContainer = .shared) {
        fetchConversations = container.fetchSupportConversations
    }

    @MainActor
    func load() async {
        isLoading = conversations.isEmpty
        errorMessage = nil
        do {
            conversations = try await fetchConversations.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
