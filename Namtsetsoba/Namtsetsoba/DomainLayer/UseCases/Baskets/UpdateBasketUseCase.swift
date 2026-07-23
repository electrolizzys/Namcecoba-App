import Foundation

/// Edits an existing basket.
protocol UpdateBasketUseCase {
    func execute(id: UUID, edit: BasketEdit) async throws
}

struct UpdateBasketUseCaseImpl: UpdateBasketUseCase {
    private let gateway: BasketGateway

    init(gateway: BasketGateway) {
        self.gateway = gateway
    }

    func execute(id: UUID, edit: BasketEdit) async throws {
        try await gateway.update(id: id, with: edit)
    }
}
