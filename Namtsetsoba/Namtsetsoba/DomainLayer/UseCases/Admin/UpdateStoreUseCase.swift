import Foundation

protocol UpdateStoreUseCase {
    func execute(id: UUID, edit: StoreEdit) async throws -> Store
}

struct UpdateStoreUseCaseImpl: UpdateStoreUseCase {
    private let gateway: AdminGateway

    init(gateway: AdminGateway) {
        self.gateway = gateway
    }

    func execute(id: UUID, edit: StoreEdit) async throws -> Store {
        try await gateway.updateStore(id: id, with: edit)
    }
}
