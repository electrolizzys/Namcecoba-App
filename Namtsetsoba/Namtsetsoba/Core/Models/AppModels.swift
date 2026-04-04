import Foundation

enum UserRole: String, Codable {
    case customer
    case business
}

struct BasketSummary: Identifiable, Equatable {
    let id: UUID
    let title: String
    let priceGel: Decimal
}
