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

    struct OrderRow: Decodable {
        let id: UUID
        let basketId: UUID
        let status: String
        let pickupCode: String
        let totalPaid: Double
        let createdAt: String

        enum CodingKeys: String, CodingKey {
            case id, status
            case basketId = "basket_id"
            case pickupCode = "pickup_code"
            case totalPaid = "total_paid"
            case createdAt = "created_at"
        }
    }

    func fetchOrders(userId: UUID) async -> [Order] {
        do {
            let rows: [OrderRow] = try await db
                .from("orders")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value

            let baskets = await BasketService.shared.fetchAvailableBaskets()
            let basketMap = Dictionary(uniqueKeysWithValues: baskets.map { ($0.id, $0) })

            return rows.compactMap { row in
                guard let basket = basketMap[row.basketId] else { return nil }

                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let date = isoFormatter.date(from: row.createdAt)
                    ?? ISO8601DateFormatter().date(from: row.createdAt)
                    ?? Date()

                let status = OrderStatus(rawValue: row.status) ?? .confirmed

                return Order(
                    id: row.id,
                    basket: basket,
                    status: status,
                    pickupCode: row.pickupCode,
                    orderDate: date,
                    totalPaid: Decimal(row.totalPaid)
                )
            }
        } catch {
            print("⚠️ Failed to fetch orders: \(error.localizedDescription)")
            return []
        }
    }
}
