import Foundation

/// Store reads and logo uploads.
protocol StoreGateway {
    func fetchStores() async throws -> [Store]
    func fetchStore(id: UUID) async throws -> Store?
    /// Uploads a JPEG logo and returns the persisted public URL string.
    func uploadLogo(storeId: UUID, jpegData: Data) async throws -> String
}
