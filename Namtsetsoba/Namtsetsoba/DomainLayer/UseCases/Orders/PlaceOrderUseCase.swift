import Foundation

/// Places an order for a basket and decrements its remaining stock.
///
/// Encapsulates the checkout business rule that used to live inside the view:
/// create the order, then reduce availability.
protocol PlaceOrderUseCase {
    func execute(userId: UUID, basket: Basket, pickupCode: String) async throws
}

struct PlaceOrderUseCaseImpl: PlaceOrderUseCase {
    private let orderGateway: OrderGateway
    private let basketGateway: BasketGateway

    init(orderGateway: OrderGateway, basketGateway: BasketGateway) {
        self.orderGateway = orderGateway
        self.basketGateway = basketGateway
    }

    func execute(userId: UUID, basket: Basket, pickupCode: String) async throws {
        try await orderGateway.createOrder(
            userId: userId,
            basketId: basket.id,
            totalPaid: basket.discountedPrice,
            pickupCode: pickupCode
        )
        try await basketGateway.decrementRemaining(basketId: basket.id)
    }
}
