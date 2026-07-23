import Foundation
import Observation

/// Presentation logic for checkout.
@Observable
final class CheckoutViewModel {
    var isProcessing = false

    @ObservationIgnored private let placeOrderUseCase: PlaceOrderUseCase

    init(container: AppContainer = .shared) {
        placeOrderUseCase = container.placeOrder
    }

    /// Places the order and returns the generated pickup code.
    func placeOrder(userId: UUID, basket: Basket) async throws -> String {
        let pickupCode = String(format: "%04d", Int.random(in: 1000...9999))
        try await placeOrderUseCase.execute(userId: userId, basket: basket, pickupCode: pickupCode)
        return pickupCode
    }
}
