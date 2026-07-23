import Foundation
import Supabase

/// Supabase-backed implementation of `StoreGateway`.
final class ApiStoreGateway: StoreGateway {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseClientProvider.client) {
        self.client = client
    }

    func fetchStores() async throws -> [Store] {
        let rows: [ApiStore] = try await client
            .from("stores")
            .select()
            .order("name")
            .execute()
            .value
        return rows.map { $0.toDomain() }
    }

    func fetchStore(id: UUID) async throws -> Store? {
        let row: ApiStore = try await client
            .from("stores")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
        return row.toDomain()
    }

    /// Uploads JPEG to Storage `store-logos/{storeId}/logo.jpg`, updates `stores.logo_url`,
    /// and returns the persisted (cache-busted) public URL string.
    func uploadLogo(storeId: UUID, jpegData: Data) async throws -> String {
        let path = "\(storeId.uuidString.lowercased())/logo.jpg"
        try await client.storage
            .from("store-logos")
            .upload(
                path,
                data: jpegData,
                options: FileOptions(cacheControl: "3600", contentType: "image/jpeg", upsert: true)
            )

        let publicURL = try client.storage.from("store-logos").getPublicURL(path: path)
        let urlString = Self.cacheBustedURL(publicURL)

        try await client
            .from("stores")
            .update(["logo_url": urlString])
            .eq("id", value: storeId)
            .execute()

        return urlString
    }

    /// Appends `v=<timestamp>` so each upload gets a distinct URL (image caches reuse the same path otherwise).
    private static func cacheBustedURL(_ publicURL: URL) -> String {
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
