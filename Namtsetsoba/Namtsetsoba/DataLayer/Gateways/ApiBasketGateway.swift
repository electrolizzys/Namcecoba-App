import Foundation
import Supabase

/// Supabase-backed implementation of `BasketGateway`.
final class ApiBasketGateway: BasketGateway {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseClientProvider.client) {
        self.client = client
    }

    func fetchAllBaskets() async throws -> [Basket] {
        let storeMap = try await fetchStoreMap()
        let basketRows: [ApiBasket] = try await client
            .from("baskets")
            .select()
            .execute()
            .value
        return basketRows.compactMap { row in
            guard let store = storeMap[row.storeId] else { return nil }
            return row.toDomain(store: store)
        }
    }

    func fetchAvailableBaskets() async throws -> [Basket] {
        let storeMap = try await fetchStoreMap()
        let basketRows: [ApiBasket] = try await client
            .from("baskets")
            .select()
            .gt("remaining_count", value: 0)
            .order("discounted_price")
            .execute()
            .value
        return basketRows.compactMap { row in
            guard let store = storeMap[row.storeId] else { return nil }
            return row.toDomain(store: store)
        }
    }

    func fetchBusinessBaskets(storeId: UUID) async throws -> [Basket] {
        let storeRows: [ApiStore] = try await client
            .from("stores")
            .select()
            .eq("id", value: storeId)
            .execute()
            .value

        guard let store = storeRows.first?.toDomain() else { return [] }

        let basketRows: [ApiBasket] = try await client
            .from("baskets")
            .select()
            .eq("store_id", value: storeId)
            .gt("remaining_count", value: 0)
            .order("created_at", ascending: false)
            .execute()
            .value

        return basketRows.map { $0.toDomain(store: store) }
    }

    func create(_ basket: NewBasket) async throws {
        try await client
            .from("baskets")
            .insert(ApiBasketInsert(from: basket))
            .execute()
    }

    func update(id: UUID, with edit: BasketEdit) async throws {
        try await client
            .from("baskets")
            .update(ApiBasketUpdate(from: edit))
            .eq("id", value: id)
            .execute()
    }

    func delete(id: UUID) async throws {
        try await client
            .from("baskets")
            .delete()
            .eq("id", value: id)
            .execute()
    }

    func decrementRemaining(basketId: UUID) async throws {
        let row: ApiBasket = try await client
            .from("baskets")
            .select()
            .eq("id", value: basketId)
            .single()
            .execute()
            .value
        let newCount = max(0, row.remainingCount - 1)
        try await client
            .from("baskets")
            .update(["remaining_count": newCount])
            .eq("id", value: basketId)
            .execute()
    }

    // MARK: - Helpers

    private func fetchStoreMap() async throws -> [UUID: Store] {
        let storeRows: [ApiStore] = try await client
            .from("stores")
            .select()
            .execute()
            .value
        return Dictionary(uniqueKeysWithValues: storeRows.map { ($0.id, $0.toDomain()) })
    }
}
