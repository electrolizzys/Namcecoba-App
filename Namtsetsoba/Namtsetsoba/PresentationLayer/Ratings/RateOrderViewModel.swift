import Foundation
import Observation

@Observable
final class RateOrderViewModel {
    var stars: Int = 0
    var comment: String = ""
    var isSubmitting = false
    var errorMessage: String?

    @ObservationIgnored private let submitRatingUseCase: SubmitRatingUseCase

    init(container: AppContainer = .shared) {
        submitRatingUseCase = container.submitRating
    }

    var canSubmit: Bool { stars >= 1 && !isSubmitting }

    @MainActor
    func submit(orderId: UUID, storeId: UUID, userId: UUID) async -> Bool {
        guard canSubmit else { return false }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        do {
            try await submitRatingUseCase.execute(
                orderId: orderId,
                storeId: storeId,
                userId: userId,
                stars: stars,
                comment: comment
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
