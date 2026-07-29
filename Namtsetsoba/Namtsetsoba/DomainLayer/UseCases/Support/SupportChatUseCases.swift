import Foundation

protocol FetchMySupportConversationUseCase {
    func execute() async throws -> SupportConversation?
}

struct FetchMySupportConversationUseCaseImpl: FetchMySupportConversationUseCase {
    private let gateway: SupportChatGateway
    init(gateway: SupportChatGateway) { self.gateway = gateway }
    func execute() async throws -> SupportConversation? {
        try await gateway.fetchMyConversation()
    }
}

protocol FetchSupportConversationsUseCase {
    func execute() async throws -> [SupportConversation]
}

struct FetchSupportConversationsUseCaseImpl: FetchSupportConversationsUseCase {
    private let gateway: SupportChatGateway
    init(gateway: SupportChatGateway) { self.gateway = gateway }
    func execute() async throws -> [SupportConversation] {
        try await gateway.fetchAllConversations()
    }
}

protocol FetchSupportConversationUseCase {
    func execute(id: UUID) async throws -> SupportConversation?
}

struct FetchSupportConversationUseCaseImpl: FetchSupportConversationUseCase {
    private let gateway: SupportChatGateway
    init(gateway: SupportChatGateway) { self.gateway = gateway }
    func execute(id: UUID) async throws -> SupportConversation? {
        try await gateway.fetchConversation(id: id)
    }
}

protocol FetchSupportMessagesUseCase {
    func execute(conversationId: UUID) async throws -> [SupportMessage]
}

struct FetchSupportMessagesUseCaseImpl: FetchSupportMessagesUseCase {
    private let gateway: SupportChatGateway
    init(gateway: SupportChatGateway) { self.gateway = gateway }
    func execute(conversationId: UUID) async throws -> [SupportMessage] {
        try await gateway.fetchMessages(conversationId: conversationId)
    }
}

protocol SendSupportChatMessageUseCase {
    func execute(body: String, conversationId: UUID?) async throws
}

struct SendSupportChatMessageUseCaseImpl: SendSupportChatMessageUseCase {
    private let gateway: SupportChatGateway
    init(gateway: SupportChatGateway) { self.gateway = gateway }
    func execute(body: String, conversationId: UUID?) async throws {
        _ = try await gateway.sendMessage(body: body, conversationId: conversationId)
    }
}

protocol OpenSupportConversationUseCase {
    func execute(userId: UUID) async throws -> SupportConversation
}

struct OpenSupportConversationUseCaseImpl: OpenSupportConversationUseCase {
    private let gateway: SupportChatGateway
    init(gateway: SupportChatGateway) { self.gateway = gateway }
    func execute(userId: UUID) async throws -> SupportConversation {
        try await gateway.openConversation(forUserId: userId)
    }
}
