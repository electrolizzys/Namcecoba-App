import Foundation

protocol CreateStoreWithVenueUseCase {
    func execute(_ draft: NewVenueOnboarding) async throws -> Store
}

struct CreateStoreWithVenueUseCaseImpl: CreateStoreWithVenueUseCase {
    private let gateway: AdminGateway

    init(gateway: AdminGateway) {
        self.gateway = gateway
    }

    func execute(_ draft: NewVenueOnboarding) async throws -> Store {
        try await gateway.createStoreWithVenue(draft)
    }
}
