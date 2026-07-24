import Foundation

protocol FetchAdminOffersUseCase {
    func execute() async throws -> [Basket]
}

struct FetchAdminOffersUseCaseImpl: FetchAdminOffersUseCase {
    private let gateway: AdminGateway

    init(gateway: AdminGateway) {
        self.gateway = gateway
    }

    func execute() async throws -> [Basket] {
        try await gateway.fetchActiveOffers()
    }
}
