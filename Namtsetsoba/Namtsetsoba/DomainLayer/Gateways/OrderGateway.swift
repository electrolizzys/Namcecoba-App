import Foundation

/// Order reads and writes.
protocol OrderGateway {
    func createOrder(userId: UUID, basketId: UUID, totalPaid: Decimal, pickupCode: String) async throws
    func fetchOrders(userId: UUID) async throws -> [Order]
    func fetchStoreOrders(storeId: UUID) async throws -> [Order]
    func updateStatus(orderId: UUID, status: OrderStatus) async throws
}
