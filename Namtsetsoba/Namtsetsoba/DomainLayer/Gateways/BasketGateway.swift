import Foundation

/// Basket reads and writes.
protocol BasketGateway {
    func fetchAllBaskets() async throws -> [Basket]
    func fetchAvailableBaskets() async throws -> [Basket]
    func fetchBusinessBaskets(storeId: UUID) async throws -> [Basket]

    func create(_ basket: NewBasket) async throws
    func update(id: UUID, with edit: BasketEdit) async throws
    func delete(id: UUID) async throws
    func decrementRemaining(basketId: UUID) async throws
}
