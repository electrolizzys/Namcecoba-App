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

    /// Uploads JPEG to Storage `store-logos/{storeId}/logo.jpg`, updates `stores.logo_url`, returns public URL string.
    func uploadStoreLogo(storeId: UUID, jpegData: Data) async throws -> String {
        let path = "\(storeId.uuidString.lowercased())/logo.jpg"
        try await supabase.storage
            .from("store-logos")
            .upload(
                path,
                data: jpegData,
                options: FileOptions(cacheControl: "3600", contentType: "image/jpeg", upsert: true)
            )

        let publicURL = try supabase.storage.from("store-logos").getPublicURL(path: path)
        let urlString = Self.persistedLogoURL(publicURL: publicURL)

        try await db
            .from("stores")
            .update(["logo_url": urlString])
            .eq("id", value: storeId)
            .execute()

        return urlString
    }

    /// Appends `v=` timestamp so each upload gets a distinct URL (AsyncImage / HTTP caches reuse same path otherwise).
    private static func persistedLogoURL(publicURL: URL) -> String {
        let stamp = String(Int(Date().timeIntervalSince1970))
        guard var components = URLComponents(url: publicURL, resolvingAgainstBaseURL: false) else {
            return "\(publicURL.absoluteString)?v=\(stamp)"
        }
        var items = components.queryItems ?? []
        items.removeAll { $0.name == "v" }
        items.append(URLQueryItem(name: "v", value: stamp))
        components.queryItems = items
        return components.url?.absoluteString ?? "\(publicURL.absoluteString)?v=\(stamp)"
    }
}
