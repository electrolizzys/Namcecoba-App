import Foundation
import Observation

@Observable
final class AdminStoreFormViewModel {
    var name = ""
    var address = ""
    var latitude = "41.7151"
    var longitude = "44.8271"
    var category: ProductCategory = .restaurant
    var openTime = "09:00"
    var closeTime = "21:00"
    var rating = "4.5"

    var accountEmail = ""
    var temporaryPassword = ""
    var accountUsername = ""

    var isSaving = false
    var errorMessage: String?
    var didSave = false

    private let editingStore: Store?

    @ObservationIgnored private let createStoreWithVenue: CreateStoreWithVenueUseCase
    @ObservationIgnored private let updateStore: UpdateStoreUseCase

    var isEditing: Bool { editingStore != nil }
    var title: String { isEditing ? "Edit Store" : "Add Store" }

    init(store: Store? = nil, container: AppContainer = .shared) {
        editingStore = store
        createStoreWithVenue = container.createStoreWithVenue
        updateStore = container.updateStore

        if let store {
            name = store.name
            address = store.address
            latitude = String(store.latitude)
            longitude = String(store.longitude)
            category = store.category
            openTime = store.openTime
            closeTime = store.closeTime
            rating = String(format: "%.1f", store.rating)
        }
    }

    @MainActor
    func save() async {
        errorMessage = nil
        guard let edit = makeStoreEdit() else {
            errorMessage = "Please fill all store fields with valid numbers."
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            if let existing = editingStore {
                _ = try await updateStore.execute(id: existing.id, edit: edit)
            } else {
                let email = accountEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                let password = temporaryPassword
                let username = accountUsername.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !email.isEmpty, password.count >= 6, !username.isEmpty else {
                    errorMessage = "Venue email, username, and password (6+ chars) are required."
                    return
                }
                let draft = NewVenueOnboarding(
                    store: edit,
                    accountEmail: email,
                    temporaryPassword: password,
                    accountUsername: username
                )
                _ = try await createStoreWithVenue.execute(draft)
            }
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func makeStoreEdit() -> StoreEdit? {
        let lat = Double(latitude.replacingOccurrences(of: ",", with: "."))
        let lon = Double(longitude.replacingOccurrences(of: ",", with: "."))
        let rate = Double(rating.replacingOccurrences(of: ",", with: "."))
        guard
            !name.trimmingCharacters(in: .whitespaces).isEmpty,
            !address.trimmingCharacters(in: .whitespaces).isEmpty,
            let lat, let lon, let rate
        else { return nil }

        return StoreEdit(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            address: address.trimmingCharacters(in: .whitespacesAndNewlines),
            latitude: lat,
            longitude: lon,
            category: category,
            openTime: openTime,
            closeTime: closeTime,
            rating: rate
        )
    }
}
