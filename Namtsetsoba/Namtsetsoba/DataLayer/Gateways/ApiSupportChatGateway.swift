import Foundation
import Supabase

/// Supabase-backed support chat.
final class ApiSupportChatGateway: SupportChatGateway {
    private let client: SupabaseClient

    private let conversationSelect = """
        id, user_id, last_message_preview, last_message_at, created_at, \
        profiles!user_id ( username, email, role )
        """

    init(client: SupabaseClient = SupabaseClientProvider.client) {
        self.client = client
    }

    func fetchMyConversation() async throws -> SupportConversation? {
        let uid = try await client.auth.session.user.id
        let rows: [ApiSupportConversation] = try await client
            .from("support_conversations")
            .select(conversationSelect)
            .eq("user_id", value: uid)
            .limit(1)
            .execute()
            .value
        return rows.first?.toDomain()
    }

    func fetchAllConversations() async throws -> [SupportConversation] {
        let rows: [ApiSupportConversation] = try await client
            .from("support_conversations")
            .select(conversationSelect)
            .order("last_message_at", ascending: false)
            .execute()
            .value
        return rows.map { $0.toDomain() }
    }

    func fetchConversation(id: UUID) async throws -> SupportConversation? {
        let rows: [ApiSupportConversation] = try await client
            .from("support_conversations")
            .select(conversationSelect)
            .eq("id", value: id)
            .limit(1)
            .execute()
            .value
        return rows.first?.toDomain()
    }

    func openConversation(forUserId userId: UUID) async throws -> SupportConversation {
        struct Params: Encodable {
            let p_user_id: UUID
        }
        let conversationId: UUID = try await client
            .rpc("open_support_conversation", params: Params(p_user_id: userId))
            .execute()
            .value
        guard let conversation = try await fetchConversation(id: conversationId) else {
            throw NSError(
                domain: "SupportChat",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Conversation could not be loaded."]
            )
        }
        return conversation
    }

    func fetchMessages(conversationId: UUID) async throws -> [SupportMessage] {
        let rows: [ApiSupportMessage] = try await client
            .from("support_messages")
            .select()
            .eq("conversation_id", value: conversationId)
            .order("created_at", ascending: true)
            .execute()
            .value
        return rows.map { $0.toDomain() }
    }

    func sendMessage(body: String, conversationId: UUID?) async throws -> UUID {
        struct Params: Encodable {
            let p_body: String
            let p_conversation_id: UUID?
        }
        let messageId: UUID = try await client
            .rpc(
                "send_support_chat_message",
                params: Params(p_body: body, p_conversation_id: conversationId)
            )
            .execute()
            .value
        return messageId
    }
}
