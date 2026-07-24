import Foundation

protocol FetchAdminUsersUseCase {
    func execute() async throws -> [UserProfile]
}

struct FetchAdminUsersUseCaseImpl: FetchAdminUsersUseCase {
    private let gateway: AdminGateway

    init(gateway: AdminGateway) {
        self.gateway = gateway
    }

    func execute() async throws -> [UserProfile] {
        try await gateway.fetchUsers()
    }
}
