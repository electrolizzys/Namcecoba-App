import Foundation

protocol SubmitRatingUseCase {
    func execute(orderId: UUID, storeId: UUID, userId: UUID, stars: Int, comment: String?) async throws
}

struct SubmitRatingUseCaseImpl: SubmitRatingUseCase {
    let gateway: RatingGateway

    func execute(orderId: UUID, storeId: UUID, userId: UUID, stars: Int, comment: String?) async throws {
        let clamped = min(5, max(1, stars))
        let trimmed = comment?.trimmingCharacters(in: .whitespacesAndNewlines)
        try await gateway.submit(
            orderId: orderId,
            storeId: storeId,
            userId: userId,
            stars: clamped,
            comment: (trimmed?.isEmpty == false) ? trimmed : nil
        )
    }
}
