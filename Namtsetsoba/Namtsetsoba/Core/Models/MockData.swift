import Foundation

enum MockData {
    private static let storeIDs = (0..<10).map { _ in UUID() }

    static let stores: [Store] = [
        Store(id: storeIDs[0], name: "Bread House", address: "Rustaveli Ave 12, Tbilisi",
              latitude: 41.6941, longitude: 44.8015, category: .bakery, rating: 4.7),
        Store(id: storeIDs[1], name: "Machakhela", address: "Aghmashenebeli Ave 28, Tbilisi",
              latitude: 41.7088, longitude: 44.7837, category: .restaurant, rating: 4.5),
        Store(id: storeIDs[2], name: "Nikora", address: "Chavchavadze Ave 5, Tbilisi",
              latitude: 41.7105, longitude: 44.7750, category: .grocery, rating: 4.2),
        Store(id: storeIDs[3], name: "Stamba Cafe", address: "Chubinashvili St 14, Tbilisi",
              latitude: 41.7070, longitude: 44.7920, category: .cafe, rating: 4.8),
        Store(id: storeIDs[4], name: "Entree", address: "Rustaveli Ave 22, Tbilisi",
              latitude: 41.6968, longitude: 44.8000, category: .cafe, rating: 4.6),
        Store(id: storeIDs[5], name: "Pasanauri", address: "Marjanishvili St 3, Tbilisi",
              latitude: 41.7110, longitude: 44.7880, category: .restaurant, rating: 4.4),
        Store(id: storeIDs[6], name: "Sweet Palace", address: "Pekini Ave 41, Tbilisi",
              latitude: 41.7220, longitude: 44.7680, category: .pastry, rating: 4.3),
        Store(id: storeIDs[7], name: "Sakhachapure N1", address: "Vake, Tbilisi",
              latitude: 41.7150, longitude: 44.7600, category: .bakery, rating: 4.1),
        Store(id: storeIDs[8], name: "Fresco", address: "Saburtalo, Tbilisi",
              latitude: 41.7250, longitude: 44.7550, category: .grocery, rating: 4.0),
        Store(id: storeIDs[9], name: "Lolita", address: "Vera, Tbilisi",
              latitude: 41.7020, longitude: 44.7900, category: .pastry, rating: 4.9),
    ]

    static let baskets: [Basket] = {
        let cal = Calendar.current
        let now = Date()

        func pickup(hoursFromNow h: Int, duration: Int = 2) -> (Date, Date) {
            let start = cal.date(byAdding: .hour, value: h, to: now)!
            let end = cal.date(byAdding: .hour, value: duration, to: start)!
            return (start, end)
        }

        let t1 = pickup(hoursFromNow: 2)
        let t2 = pickup(hoursFromNow: 3)
        let t3 = pickup(hoursFromNow: 1)
        let t4 = pickup(hoursFromNow: 4)
        let t5 = pickup(hoursFromNow: 2, duration: 3)
        let t6 = pickup(hoursFromNow: 5)
        let t7 = pickup(hoursFromNow: 1, duration: 1)
        let t8 = pickup(hoursFromNow: 3, duration: 2)

        return [
            Basket(id: UUID(), store: stores[0], title: "Surprise Bread Basket",
                   description: "A mix of today's fresh bread, pastries, and baked goods from our artisan bakery.",
                   originalPrice: 15.00, discountedPrice: 5.99,
                   pickupStartTime: t1.0, pickupEndTime: t1.1,
                   itemsDescription: "Assorted bread loaves, croissants, and pastries",
                   remainingCount: 3, distanceKm: 1.2),

            Basket(id: UUID(), store: stores[1], title: "Georgian Feast Box",
                   description: "Leftover dishes from today's lunch menu including khinkali and salads.",
                   originalPrice: 25.00, discountedPrice: 8.99,
                   pickupStartTime: t2.0, pickupEndTime: t2.1,
                   itemsDescription: "Khinkali, salad, bread, and a surprise side dish",
                   remainingCount: 2, distanceKm: 2.5),

            Basket(id: UUID(), store: stores[2], title: "Fresh Groceries Pack",
                   description: "Mixed fruits, vegetables, and dairy products nearing their best-by date.",
                   originalPrice: 20.00, discountedPrice: 6.99,
                   pickupStartTime: t3.0, pickupEndTime: t3.1,
                   itemsDescription: "Fruits, veggies, yogurt, and cheese",
                   remainingCount: 5, distanceKm: 0.8),

            Basket(id: UUID(), store: stores[3], title: "Afternoon Treats",
                   description: "Premium coffee-shop pastries and one complimentary coffee.",
                   originalPrice: 18.00, discountedPrice: 6.49,
                   pickupStartTime: t4.0, pickupEndTime: t4.1,
                   itemsDescription: "Croissant, muffin, cookie, and drip coffee",
                   remainingCount: 4, distanceKm: 1.5),

            Basket(id: UUID(), store: stores[4], title: "Cafe Lunch Surprise",
                   description: "Today's unsold lunch specials packaged fresh.",
                   originalPrice: 22.00, discountedPrice: 7.99,
                   pickupStartTime: t5.0, pickupEndTime: t5.1,
                   itemsDescription: "Sandwich, soup, and a dessert",
                   remainingCount: 1, distanceKm: 1.0),

            Basket(id: UUID(), store: stores[5], title: "Dinner Rescue Box",
                   description: "Tonight's specials that won't make it to tomorrow.",
                   originalPrice: 30.00, discountedPrice: 10.99,
                   pickupStartTime: t6.0, pickupEndTime: t6.1,
                   itemsDescription: "Main course, bread, and salad",
                   remainingCount: 3, distanceKm: 3.2),

            Basket(id: UUID(), store: stores[6], title: "Sweet Surprise",
                   description: "Assorted cakes and pastries from today's display.",
                   originalPrice: 28.00, discountedPrice: 9.49,
                   pickupStartTime: t7.0, pickupEndTime: t7.1,
                   itemsDescription: "Cake slices, eclairs, and macarons",
                   remainingCount: 2, distanceKm: 4.0),

            Basket(id: UUID(), store: stores[7], title: "Khachapuri Bundle",
                   description: "Fresh khachapuri varieties baked this morning.",
                   originalPrice: 12.00, discountedPrice: 4.49,
                   pickupStartTime: t8.0, pickupEndTime: t8.1,
                   itemsDescription: "Imeruli and Megruli khachapuri",
                   remainingCount: 6, distanceKm: 2.1),
        ]
    }()

    static let frequentStoreIds: Set<UUID> = [storeIDs[0], storeIDs[3]]

    static let businessBaskets: [Basket] = {
        let cal = Calendar.current
        let now = Date()

        func pickup(hoursFromNow h: Int, duration: Int = 2) -> (Date, Date) {
            let start = cal.date(byAdding: .hour, value: h, to: now)!
            let end = cal.date(byAdding: .hour, value: duration, to: start)!
            return (start, end)
        }

        let store = stores[0]
        let t1 = pickup(hoursFromNow: 2)
        let t2 = pickup(hoursFromNow: 4)
        let t3 = pickup(hoursFromNow: 6)

        return [
            Basket(id: UUID(), store: store, title: "Surprise Bread Basket",
                   description: "A mix of today's fresh bread, pastries, and baked goods.",
                   originalPrice: 15.00, discountedPrice: 5.99,
                   pickupStartTime: t1.0, pickupEndTime: t1.1,
                   itemsDescription: "Assorted bread loaves, croissants, and pastries",
                   remainingCount: 3, distanceKm: nil),

            Basket(id: UUID(), store: store, title: "Evening Pastry Box",
                   description: "Leftover pastries from the afternoon bake.",
                   originalPrice: 18.00, discountedPrice: 6.49,
                   pickupStartTime: t2.0, pickupEndTime: t2.1,
                   itemsDescription: "Cinnamon rolls, danishes, and muffins",
                   remainingCount: 5, distanceKm: nil),

            Basket(id: UUID(), store: store, title: "Khachapuri Bundle",
                   description: "Fresh khachapuri varieties baked this morning.",
                   originalPrice: 12.00, discountedPrice: 4.49,
                   pickupStartTime: t3.0, pickupEndTime: t3.1,
                   itemsDescription: "Imeruli and Megruli khachapuri",
                   remainingCount: 2, distanceKm: nil),
        ]
    }()
}
