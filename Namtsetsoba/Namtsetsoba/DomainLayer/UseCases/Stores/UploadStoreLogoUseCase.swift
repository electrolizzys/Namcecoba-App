import Foundation

/// Uploads a new store logo and returns the fresh store after the change.
protocol UploadStoreLogoUseCase {
    func execute(storeId: UUID, jpegData: Data) async throws -> Store?
}

struct UploadStoreLogoUseCaseImpl: UploadStoreLogoUseCase {
    private let gateway: StoreGateway

    init(gateway: StoreGateway) {
        self.gateway = gateway
    }

    func execute(storeId: UUID, jpegData: Data) async throws -> Store? {
        _ = try await gateway.uploadLogo(storeId: storeId, jpegData: jpegData)
        return try await gateway.fetchStore(id: storeId)
    }
}
