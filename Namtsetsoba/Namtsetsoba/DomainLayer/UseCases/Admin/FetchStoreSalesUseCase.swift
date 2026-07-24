import Foundation

protocol FetchStoreSalesUseCase {
    func execute(period: SalesPeriod) async throws -> [StoreSalesSummary]
}

struct FetchStoreSalesUseCaseImpl: FetchStoreSalesUseCase {
    private let gateway: AdminGateway

    init(gateway: AdminGateway) {
        self.gateway = gateway
    }

    func execute(period: SalesPeriod) async throws -> [StoreSalesSummary] {
        try await gateway.fetchStoreSales(period: period)
    }
}
