import Foundation
import Supabase

final class StoreService {
    static let shared = StoreService()
    private let db = supabase

    private init() {}

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

        enum CodingKeys: String, CodingKey {
            case id, name, address, latitude, longitude, category, rating
            case openTime = "open_time"
            case closeTime = "close_time"
        }

        func toStore() -> Store {
            Store(
                id: id, name: name, address: address,
                latitude: latitude, longitude: longitude,
                category: ProductCategory(rawValue: category) ?? .restaurant,
                rating: rating,
                openTime: openTime ?? "09:00",
                closeTime: closeTime ?? "21:00"
            )
        }
    }

    func fetchStores() async -> [Store] {
        do {
            let rows: [StoreRow] = try await db
                .from("stores")
                .select()
                .order("name")
                .execute()
                .value
            return rows.map { $0.toStore() }
        } catch {
            print("⚠️ Supabase stores fetch failed, using mock data: \(error.localizedDescription)")
            return MockData.stores
        }
    }

    func fetchStore(id: UUID) async -> Store? {
        do {
            let row: StoreRow = try await db
                .from("stores")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            return row.toStore()
        } catch {
            print("⚠️ Supabase store fetch failed: \(error.localizedDescription)")
            return nil
        }
    }
}
