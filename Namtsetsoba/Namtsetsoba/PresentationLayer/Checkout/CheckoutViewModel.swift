import Foundation
import Observation

/// Presentation logic for checkout.
@Observable
final class CheckoutViewModel {
    var isProcessing = false
    var errorMessage: String?

    @ObservationIgnored private let placeOrderUseCase: PlaceOrderUseCase

    init(container: AppContainer = .shared) {
        placeOrderUseCase = container.placeOrder
    }

    /// Simulates payment, places the order, and returns the pickup code on success.
    @MainActor
    func checkout(userId: UUID?, basket: Basket) async -> String? {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        try? await Task.sleep(for: .seconds(1.5))

        guard let userId else {
            errorMessage = "Not logged in."
            return nil
        }

        do {
            let pickupCode = String(format: "%04d", Int.random(in: 1000...9999))
            try await placeOrderUseCase.execute(userId: userId, basket: basket, pickupCode: pickupCode)
            return pickupCode
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
