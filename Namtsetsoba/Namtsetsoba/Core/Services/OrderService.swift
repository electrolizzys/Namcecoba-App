import Foundation
import Supabase

final class OrderService {
    static let shared = OrderService()
    private let db = supabase

    private init() {}

    struct OrderInsert: Encodable {
        let userId: UUID
        let basketId: UUID
        let status: String
        let pickupCode: String
        let totalPaid: Double

        enum CodingKeys: String, CodingKey {
            case status
            case userId = "user_id"
            case basketId = "basket_id"
            case pickupCode = "pickup_code"
            case totalPaid = "total_paid"
        }
    }

    /// Creates an order in Supabase. Requires authenticated user.
    func createOrder(userId: UUID, basketId: UUID, totalPaid: Decimal, pickupCode: String) async throws {
        let insert = OrderInsert(
            userId: userId,
            basketId: basketId,
            status: "confirmed",
            pickupCode: pickupCode,
            totalPaid: NSDecimalNumber(decimal: totalPaid).doubleValue
        )
        try await db
            .from("orders")
            .insert(insert)
            .execute()
    }

    /// Fetches orders for the current user. Requires authenticated user.
    func fetchOrders(userId: UUID) async -> [Order] {
        // Orders still use local AppState until auth is fully merged
        return []
    }
}
