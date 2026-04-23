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

    func fetchStoreOrders(storeId: UUID) async -> [Order] {
        do {
            let basketRows: [BasketService.BasketRow] = try await db
                .from("baskets")
                .select()
                .eq("store_id", value: storeId)
                .execute()
                .value

            let basketIds = basketRows.map(\.id)
            guard !basketIds.isEmpty else { return [] }

            let storeRows: [BasketService.StoreRow] = try await db
                .from("stores")
                .select()
                .eq("id", value: storeId)
                .execute()
                .value

            guard let store = storeRows.first?.toStore() else { return [] }
            let basketMap = Dictionary(uniqueKeysWithValues: basketRows.map {
                ($0.id, $0.toBasket(store: store))
            })

            let rows: [OrderRow] = try await db
                .from("orders")
                .select()
                .in("basket_id", values: basketIds.map(\.uuidString))
                .order("created_at", ascending: false)
                .execute()
                .value

            return rows.compactMap { row in
                guard let basket = basketMap[row.basketId] else { return nil }

                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let date = isoFormatter.date(from: row.createdAt)
                    ?? ISO8601DateFormatter().date(from: row.createdAt)
                    ?? Date()

                return Order(
                    id: row.id,
                    basket: basket,
                    status: OrderStatus(rawValue: row.status) ?? .confirmed,
                    pickupCode: row.pickupCode,
                    orderDate: date,
                    totalPaid: Decimal(row.totalPaid)
                )
            }
        } catch {
            print("⚠️ Failed to fetch store orders: \(error.localizedDescription)")
            return []
        }
    }

    func updateOrderStatus(orderId: UUID, status: String) async throws {
        try await db
            .from("orders")
            .update(["status": status])
            .eq("id", value: orderId)
            .execute()
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

            let baskets = await BasketService.shared.fetchAllBaskets()
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
