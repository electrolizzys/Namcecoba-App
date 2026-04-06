import Foundation
import Supabase

final class BasketService {
    static let shared = BasketService()
    private let db = NetworkEnvironment.supabase

    private init() {}

    // MARK: - Row types for Supabase decoding

    struct StoreRow: Decodable {
        let id: UUID
        let name: String
        let address: String
        let latitude: Double
        let longitude: Double
        let category: String
        let rating: Double

        func toStore() -> Store {
            Store(
                id: id, name: name, address: address,
                latitude: latitude, longitude: longitude,
                category: ProductCategory(rawValue: category) ?? .restaurant,
                rating: rating
            )
        }
    }

    struct BasketRow: Decodable {
        let id: UUID
        let title: String
        let description: String?
        let originalPrice: Double
        let discountedPrice: Double
        let pickupStartTime: Date
        let pickupEndTime: Date
        let itemsDescription: String?
        let remainingCount: Int
        let store: StoreRow

        func toBasket() -> Basket {
            Basket(
                id: id,
                store: store.toStore(),
                title: title,
                description: description ?? "",
                originalPrice: Decimal(originalPrice),
                discountedPrice: Decimal(discountedPrice),
                pickupStartTime: pickupStartTime,
                pickupEndTime: pickupEndTime,
                itemsDescription: itemsDescription ?? "",
                remainingCount: remainingCount,
                distanceKm: nil
            )
        }
    }

    struct BasketInsert: Encodable {
        let storeId: UUID
        let title: String
        let description: String
        let originalPrice: Double
        let discountedPrice: Double
        let pickupStartTime: Date
        let pickupEndTime: Date
        let itemsDescription: String
        let remainingCount: Int
    }

    // MARK: - Customer: browse available baskets

    func fetchAvailableBaskets() async -> [Basket] {
        do {
            let now = ISO8601DateFormatter().string(from: Date())
            let rows: [BasketRow] = try await db
                .from("baskets")
                .select("*, store:stores(*)")
                .gt("remaining_count", value: 0)
                .gte("pickup_end_time", value: now)
                .order("discounted_price")
                .execute()
                .value
            return rows.map { $0.toBasket() }
        } catch {
            print("⚠️ Supabase baskets fetch failed, using mock data: \(error.localizedDescription)")
            return MockData.baskets
        }
    }

    // MARK: - Business: manage own baskets

    func fetchBusinessBaskets(storeId: UUID) async -> [Basket] {
        do {
            let rows: [BasketRow] = try await db
                .from("baskets")
                .select("*, store:stores(*)")
                .eq("store_id", value: storeId)
                .order("created_at", ascending: false)
                .execute()
                .value
            return rows.map { $0.toBasket() }
        } catch {
            print("⚠️ Supabase business baskets fetch failed, using mock data: \(error.localizedDescription)")
            return MockData.businessBaskets
        }
    }

    func createBasket(_ insert: BasketInsert) async throws {
        try await db
            .from("baskets")
            .insert(insert)
            .execute()
    }

    func deleteBasket(id: UUID) async throws {
        try await db
            .from("baskets")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
