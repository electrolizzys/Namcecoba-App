import Foundation
import Supabase

final class OrderService {
    static let shared = OrderService()
    private let db = NetworkEnvironment.supabase

    private init() {}

    struct OrderInsert: Encodable {
        let userId: UUID
        let basketId: UUID
        let status: String
        let pickupCode: String
        let totalPaid: Double
    }

    struct OrderRow: Decodable {
        let id: UUID
        let status: String
        let pickupCode: String
        let totalPaid: Double
        let createdAt: Date
        let basket: BasketService.BasketRow

        func toOrder() -> Order {
            Order(
                id: id,
                basket: basket.toBasket(),
                status: OrderStatus(rawValue: status) ?? .confirmed,
                pickupCode: pickupCode,
                orderDate: createdAt,
                totalPaid: Decimal(totalPaid)
            )
        }
    }

    /// Creates an order in Supabase. Requires authenticated user.
    /// Call this after your partner's auth is merged.
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
        do {
            let rows: [OrderRow] = try await db
                .from("orders")
                .select("*, basket:baskets(*, store:stores(*))")
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value
            return rows.map { $0.toOrder() }
        } catch {
            print("⚠️ Supabase orders fetch failed: \(error.localizedDescription)")
            return []
        }
    }
}
