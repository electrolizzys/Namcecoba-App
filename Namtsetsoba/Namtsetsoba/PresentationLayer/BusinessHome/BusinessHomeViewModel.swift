import Foundation
import Observation

/// Presentation logic for the venue "My Products" screen and its add/edit form.
@Observable
final class BusinessHomeViewModel {
    @ObservationIgnored private let fetchBusinessBasketsUseCase: FetchBusinessBasketsUseCase
    @ObservationIgnored private let createBasketUseCase: CreateBasketUseCase
    @ObservationIgnored private let updateBasketUseCase: UpdateBasketUseCase
    @ObservationIgnored private let deleteBasketUseCase: DeleteBasketUseCase

    init(container: AppContainer = .shared) {
        fetchBusinessBasketsUseCase = container.fetchBusinessBaskets
        createBasketUseCase = container.createBasket
        updateBasketUseCase = container.updateBasket
        deleteBasketUseCase = container.deleteBasket
    }

    func loadBaskets(storeId: UUID) async -> [Basket] {
        (try? await fetchBusinessBasketsUseCase.execute(storeId: storeId)) ?? []
    }

    func create(_ basket: NewBasket) async throws {
        try await createBasketUseCase.execute(basket)
    }

    func update(id: UUID, edit: BasketEdit) async throws {
        try await updateBasketUseCase.execute(id: id, edit: edit)
    }

    func delete(id: UUID) async throws {
        try await deleteBasketUseCase.execute(id: id)
    }
}

// MARK: - Add / Edit Basket Form

enum AddBasketFormError: LocalizedError {
    case invalidPrice

    var errorDescription: String? {
        switch self {
        case .invalidPrice: "Please enter valid prices."
        }
    }
}

/// Owns the add/edit basket form state, validation and persistence.
@Observable
final class AddBasketFormViewModel {
    var title = ""
    var description = ""
    var itemsDescription = ""
    var originalPrice = ""
    var discountedPrice = ""
    var pickupStart = Date().addingTimeInterval(3600)
    var pickupEnd = Date().addingTimeInterval(3600 * 3)
    var availableCount = 5

    @ObservationIgnored let store: Store
    @ObservationIgnored let editingBasket: Basket?
    @ObservationIgnored private let createBasketUseCase: CreateBasketUseCase
    @ObservationIgnored private let updateBasketUseCase: UpdateBasketUseCase

    init(store: Store, editingBasket: Basket?, container: AppContainer = .shared) {
        self.store = store
        self.editingBasket = editingBasket
        createBasketUseCase = container.createBasket
        updateBasketUseCase = container.updateBasket
        populateFromEditingBasket()
    }

    var isEditing: Bool { editingBasket != nil }

    var isValid: Bool {
        !title.isEmpty && !itemsDescription.isEmpty && parsedDecimals() != nil
    }

    var availableCountRange: ClosedRange<Int> {
        isEditing ? 0...50 : 1...50
    }

    /// Creates or updates the basket. The caller handles refresh + dismiss.
    func save() async throws {
        guard let (origPrice, discPrice) = parsedDecimals() else {
            throw AddBasketFormError.invalidPrice
        }

        if let existing = editingBasket {
            let edit = BasketEdit(
                title: title,
                description: description,
                originalPrice: origPrice,
                discountedPrice: discPrice,
                pickupStartTime: pickupStart,
                pickupEndTime: pickupEnd,
                itemsDescription: itemsDescription,
                remainingCount: max(0, availableCount)
            )
            try await updateBasketUseCase.execute(id: existing.id, edit: edit)
        } else {
            let newBasket = NewBasket(
                storeId: store.id,
                title: title,
                description: description,
                originalPrice: origPrice,
                discountedPrice: discPrice,
                pickupStartTime: pickupStart,
                pickupEndTime: pickupEnd,
                itemsDescription: itemsDescription,
                remainingCount: max(1, availableCount)
            )
            try await createBasketUseCase.execute(newBasket)
        }
    }

    private func populateFromEditingBasket() {
        guard let basket = editingBasket else { return }
        title = basket.title
        description = basket.description
        itemsDescription = basket.itemsDescription
        originalPrice = Self.priceFieldString(basket.originalPrice)
        discountedPrice = Self.priceFieldString(basket.discountedPrice)
        pickupStart = basket.pickupStartTime
        pickupEnd = basket.pickupEndTime
        availableCount = basket.remainingCount
    }

    private func parsedDecimals() -> (Decimal, Decimal)? {
        let origStr = originalPrice.replacingOccurrences(of: ",", with: ".")
        let discStr = discountedPrice.replacingOccurrences(of: ",", with: ".")
        guard let orig = Decimal(string: origStr), let disc = Decimal(string: discStr) else {
            return nil
        }
        return (orig, disc)
    }

    private static func priceFieldString(_ amount: Decimal) -> String {
        String(format: "%.2f", NSDecimalNumber(decimal: amount).doubleValue)
    }
}
