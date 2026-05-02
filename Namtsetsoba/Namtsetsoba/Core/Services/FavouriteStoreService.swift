import Foundation
import Supabase

final class FavouriteStoreService {
    static let shared = FavouriteStoreService()
    private let db = supabase

    private init() {}

    struct FavouriteInsert: Encodable {
        let userId: UUID
        let storeId: UUID

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case storeId = "store_id"
        }
    }

    struct FavouriteRow: Decodable {
        let storeId: UUID

        enum CodingKeys: String, CodingKey {
            case storeId = "store_id"
        }
    }

    func fetchStoreIds(userId: UUID) async -> Set<UUID> {
        do {
            let rows: [FavouriteRow] = try await db
                .from("favourite_stores")
                .select("store_id")
                .eq("user_id", value: userId)
                .execute()
                .value
            return Set(rows.map(\.storeId))
        } catch {
            print("⚠️ Failed to fetch favourite stores: \(error.localizedDescription)")
            return []
        }
    }

    func add(userId: UUID, storeId: UUID) async {
        do {
            try await db
                .from("favourite_stores")
                .insert(FavouriteInsert(userId: userId, storeId: storeId))
                .execute()
        } catch {
            print("⚠️ Failed to add favourite store: \(error.localizedDescription)")
        }
    }

    func remove(userId: UUID, storeId: UUID) async {
        do {
            try await db
                .from("favourite_stores")
                .delete()
                .eq("user_id", value: userId)
                .eq("store_id", value: storeId)
                .execute()
        } catch {
            print("⚠️ Failed to remove favourite store: \(error.localizedDescription)")
        }
    }
}
