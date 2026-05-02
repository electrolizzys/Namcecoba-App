import Foundation
import Supabase

final class BasketService {
    static let shared = BasketService()
    private let db = supabase

    private init() {}

    // MARK: - Row types matching database columns

    struct StoreRow: Decodable {
        let id: UUID
        let name: String
        let address: String
        let latitude: Double
        let longitude: Double
        let category: String
        let rating: Double
        let openTime: String?
        let closeTime: String?
        let logoURL: String?

        enum CodingKeys: String, CodingKey {
            case id, name, address, latitude, longitude, category, rating
            case openTime = "open_time"
            case closeTime = "close_time"
            case logoURL = "logo_url"
        }

        func toStore() -> Store {
            Store(
                id: id, name: name, address: address,
                latitude: latitude, longitude: longitude,
                category: ProductCategory(rawValue: category) ?? .restaurant,
                rating: rating,
                openTime: openTime ?? "09:00",
                closeTime: closeTime ?? "21:00",
                logoURL: logoURL
            )
        }
    }

    struct BasketRow: Decodable {
        let id: UUID
        let storeId: UUID
        let title: String
        let description: String?
        let originalPrice: Double
        let discountedPrice: Double
        let pickupStartTime: String
        let pickupEndTime: String
        let itemsDescription: String?
        let remainingCount: Int

        enum CodingKeys: String, CodingKey {
            case id, title, description
            case storeId = "store_id"
            case originalPrice = "original_price"
            case discountedPrice = "discounted_price"
            case pickupStartTime = "pickup_start_time"
            case pickupEndTime = "pickup_end_time"
            case itemsDescription = "items_description"
            case remainingCount = "remaining_count"
        }

        func toBasket(store: Store) -> Basket {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            let start = isoFormatter.date(from: pickupStartTime)
                ?? ISO8601DateFormatter().date(from: pickupStartTime)
                ?? Date()
            let end = isoFormatter.date(from: pickupEndTime)
                ?? ISO8601DateFormatter().date(from: pickupEndTime)
                ?? Date()

            return Basket(
                id: id,
                store: store,
                title: title,
                description: description ?? "",
                originalPrice: Decimal(originalPrice),
                discountedPrice: Decimal(discountedPrice),
                pickupStartTime: start,
                pickupEndTime: end,
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
        let pickupStartTime: String
        let pickupEndTime: String
        let itemsDescription: String
        let remainingCount: Int

        enum CodingKeys: String, CodingKey {
            case title, description
            case storeId = "store_id"
            case originalPrice = "original_price"
            case discountedPrice = "discounted_price"
            case pickupStartTime = "pickup_start_time"
            case pickupEndTime = "pickup_end_time"
            case itemsDescription = "items_description"
            case remainingCount = "remaining_count"
        }
    }

    struct BasketUpdate: Encodable {
        let title: String
        let description: String
        let originalPrice: Double
        let discountedPrice: Double
        let pickupStartTime: String
        let pickupEndTime: String
        let itemsDescription: String
        let remainingCount: Int

        enum CodingKeys: String, CodingKey {
            case title, description
            case originalPrice = "original_price"
            case discountedPrice = "discounted_price"
            case pickupStartTime = "pickup_start_time"
            case pickupEndTime = "pickup_end_time"
            case itemsDescription = "items_description"
            case remainingCount = "remaining_count"
        }
    }

    func fetchAllBaskets() async -> [Basket] {
        do {
            let storeRows: [StoreRow] = try await db
                .from("stores")
                .select()
                .execute()
                .value

            let storeMap = Dictionary(uniqueKeysWithValues: storeRows.map { ($0.id, $0.toStore()) })

            let basketRows: [BasketRow] = try await db
                .from("baskets")
                .select()
                .execute()
                .value

            return basketRows.compactMap { row in
                guard let store = storeMap[row.storeId] else { return nil }
                return row.toBasket(store: store)
            }
        } catch {
            print("⚠️ Supabase all baskets fetch failed: \(error)")
            return []
        }
    }

    // MARK: - Customer: browse available baskets

    func fetchAvailableBaskets() async -> [Basket] {
        do {
            let storeRows: [StoreRow] = try await db
                .from("stores")
                .select()
                .execute()
                .value

            let storeMap = Dictionary(uniqueKeysWithValues: storeRows.map { ($0.id, $0.toStore()) })

            let basketRows: [BasketRow] = try await db
                .from("baskets")
                .select()
                .gt("remaining_count", value: 0)
                .order("discounted_price")
                .execute()
                .value

            return basketRows.compactMap { row in
                guard let store = storeMap[row.storeId] else { return nil }
                return row.toBasket(store: store)
            }
        } catch {
            print("⚠️ Supabase baskets fetch failed, using mock data: \(error)")
            return MockData.baskets
        }
    }

    // MARK: - Business: manage own baskets

    func fetchBusinessBaskets(storeId: UUID) async -> [Basket] {
        do {
            let storeRows: [StoreRow] = try await db
                .from("stores")
                .select()
                .eq("id", value: storeId)
                .execute()
                .value

            guard let store = storeRows.first?.toStore() else { return [] }

            let basketRows: [BasketRow] = try await db
                .from("baskets")
                .select()
                .eq("store_id", value: storeId)
                .gt("remaining_count", value: 0)
                .order("created_at", ascending: false)
                .execute()
                .value

            return basketRows.map { $0.toBasket(store: store) }
        } catch {
            print("⚠️ Supabase business baskets fetch failed: \(error.localizedDescription)")
            return []
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

    func updateBasket(id: UUID, update: BasketUpdate) async throws {
        try await db
            .from("baskets")
            .update(update)
            .eq("id", value: id)
            .execute()
    }

    func decrementRemainingCount(basketId: UUID) async throws {
        let row: BasketRow = try await db
            .from("baskets")
            .select()
            .eq("id", value: basketId)
            .single()
            .execute()
            .value
        let newCount = max(0, row.remainingCount - 1)
        try await db
            .from("baskets")
            .update(["remaining_count": newCount])
            .eq("id", value: basketId)
            .execute()
    }
}
