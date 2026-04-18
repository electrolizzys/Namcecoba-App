import Foundation
import SwiftUI
import Observation

enum UserRole: String, Codable {
    case customer
    case business
}

// MARK: - Product Category

enum ProductCategory: String, CaseIterable, Identifiable {
    case bakery = "Bakery"
    case restaurant = "Restaurant"
    case grocery = "Grocery"
    case cafe = "Cafe"
    case pastry = "Pastry"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .bakery: "🍞"
        case .restaurant: "🍽️"
        case .grocery: "🛒"
        case .cafe: "☕"
        case .pastry: "🧁"
        }
    }
}

// MARK: - Sort Option

enum SortOption: String, CaseIterable, Identifiable {
    case price = "Price"
    case distance = "Distance"
    case topPicks = "Your Favorites"
    case bestDeal = "Best Deals"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .price: "banknote"
        case .distance: "location"
        case .topPicks: "heart.fill"
        case .bestDeal: "percent"
        }
    }
}

// MARK: - Store

struct Store: Identifiable, Hashable {
    let id: UUID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let category: ProductCategory
    let rating: Double
}

// MARK: - Basket

struct Basket: Identifiable, Hashable {
    let id: UUID
    let store: Store
    let title: String
    let description: String
    let originalPrice: Decimal
    let discountedPrice: Decimal
    let pickupStartTime: Date
    let pickupEndTime: Date
    let itemsDescription: String
    let remainingCount: Int
    let distanceKm: Double?

    var savingsPercent: Int {
        let orig = NSDecimalNumber(decimal: originalPrice).doubleValue
        let disc = NSDecimalNumber(decimal: discountedPrice).doubleValue
        guard orig > 0 else { return 0 }
        return Int(((orig - disc) / orig) * 100)
    }

    static func == (lhs: Basket, rhs: Basket) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Order

enum OrderStatus: String, Codable {
    case confirmed
    case readyForPickup
    case pickedUp
    case cancelled

    var displayName: String {
        switch self {
        case .confirmed: "Confirmed"
        case .readyForPickup: "Ready for Pickup"
        case .pickedUp: "Picked Up"
        case .cancelled: "Cancelled"
        }
    }

    var color: Color {
        switch self {
        case .confirmed: .blue
        case .readyForPickup: .green
        case .pickedUp: .secondary
        case .cancelled: .red
        }
    }

    var systemImage: String {
        switch self {
        case .confirmed: "checkmark.circle.fill"
        case .readyForPickup: "bag.fill"
        case .pickedUp: "checkmark.seal.fill"
        case .cancelled: "xmark.circle.fill"
        }
    }
}

struct Order: Identifiable {
    let id: UUID
    let basket: Basket
    var status: OrderStatus
    let pickupCode: String
    let orderDate: Date
    let totalPaid: Decimal
}

// MARK: - Shared App State

@Observable
final class AppState {
    var currentRole: UserRole = .customer
    var orders: [Order] = []
    var frequentStoreIds: Set<UUID> = MockData.frequentStoreIds

    var businessStore: Store = MockData.stores[0]
    var businessBaskets: [Basket] = MockData.businessBaskets

    func placeOrder(for basket: Basket) -> Order {
        let code = String(format: "%04d", Int.random(in: 1000...9999))
        let order = Order(
            id: UUID(),
            basket: basket,
            status: .confirmed,
            pickupCode: code,
            orderDate: Date(),
            totalPaid: basket.discountedPrice
        )
        orders.insert(order, at: 0)
        frequentStoreIds.insert(basket.store.id)
        return order
    }

    func publishBasket(_ basket: Basket) {
        businessBaskets.insert(basket, at: 0)
    }

    func removeBasket(_ basket: Basket) {
        businessBaskets.removeAll { $0.id == basket.id }
    }
}
