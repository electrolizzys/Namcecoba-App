import Foundation

protocol FetchRatedOrderIdsUseCase {
    func execute(userId: UUID) async throws -> Set<UUID>
}

struct FetchRatedOrderIdsUseCaseImpl: FetchRatedOrderIdsUseCase {
    let gateway: RatingGateway

    func execute(userId: UUID) async throws -> Set<UUID> {
        try await gateway.fetchRatedOrderIds(userId: userId)
    }
}
