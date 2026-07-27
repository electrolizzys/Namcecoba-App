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

    var accountEmail = ""
    var temporaryPassword = ""
    var accountUsername = ""

    /// Optional store photo chosen during creation; uploaded once the store exists.
    var photoData: Data?

    var isSaving = false
    var errorMessage: String?
    var didSave = false

    private let editingStore: Store?

    @ObservationIgnored private let createStoreWithVenue: CreateStoreWithVenueUseCase
    @ObservationIgnored private let updateStore: UpdateStoreUseCase
    @ObservationIgnored private let uploadStoreLogo: UploadStoreLogoUseCase

    var isEditing: Bool { editingStore != nil }
    var title: String { isEditing ? "Edit Store" : "Add Venue" }

    var parsedLatitude: Double? { Double(latitude.replacingOccurrences(of: ",", with: ".")) }
    var parsedLongitude: Double? { Double(longitude.replacingOccurrences(of: ",", with: ".")) }
    var hasCoordinate: Bool { parsedLatitude != nil && parsedLongitude != nil }

    init(store: Store? = nil, container: AppContainer = .shared) {
        editingStore = store
        createStoreWithVenue = container.createStoreWithVenue
        updateStore = container.updateStore
        uploadStoreLogo = container.uploadStoreLogo

        if let store {
            name = store.name
            address = store.address
            latitude = String(store.latitude)
            longitude = String(store.longitude)
            category = store.category
            openTime = store.openTime
            closeTime = store.closeTime
        }
    }

    // MARK: - Editor helpers

    var openTimeDate: Date {
        get { Self.date(from: openTime) }
        set { openTime = Self.string(from: newValue) }
    }

    var closeTimeDate: Date {
        get { Self.date(from: closeTime) }
        set { closeTime = Self.string(from: newValue) }
    }

    func setCoordinate(latitude lat: Double, longitude lon: Double) {
        latitude = String(format: "%.5f", lat)
        longitude = String(format: "%.5f", lon)
    }

    // MARK: - Persistence

    @MainActor
    func save() async {
        errorMessage = nil
        guard let edit = makeStoreEdit() else {
            errorMessage = "Add a name, an address, and pick a location on the map."
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
                    errorMessage = "Venue email, username, and a password of at least 6 characters are required."
                    return
                }
                let draft = NewVenueOnboarding(
                    store: edit,
                    accountEmail: email,
                    temporaryPassword: password,
                    accountUsername: username
                )
                let created = try await createStoreWithVenue.execute(draft)
                if let photoData {
                    _ = try? await uploadStoreLogo.execute(storeId: created.id, jpegData: photoData)
                }
            }
            didSave = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reset() {
        name = ""
        address = ""
        latitude = "41.7151"
        longitude = "44.8271"
        category = .restaurant
        openTime = "09:00"
        closeTime = "21:00"
        accountEmail = ""
        temporaryPassword = ""
        accountUsername = ""
        photoData = nil
        errorMessage = nil
        didSave = false
    }

    private func makeStoreEdit() -> StoreEdit? {
        guard
            !name.trimmingCharacters(in: .whitespaces).isEmpty,
            !address.trimmingCharacters(in: .whitespaces).isEmpty,
            let lat = parsedLatitude,
            let lon = parsedLongitude
        else { return nil }

        return StoreEdit(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            address: address.trimmingCharacters(in: .whitespacesAndNewlines),
            latitude: lat,
            longitude: lon,
            category: category,
            openTime: openTime,
            closeTime: closeTime,
            // Ratings come from real customer feedback; new stores seed at 0 and the
            // presentation layer shows an estimated baseline until reviews arrive.
            rating: editingStore?.rating ?? 0
        )
    }

    private static func date(from hhmm: String) -> Date {
        let parts = hhmm.split(separator: ":")
        var comps = DateComponents()
        comps.hour = Int(parts.first ?? "9") ?? 9
        comps.minute = parts.count > 1 ? (Int(parts[1]) ?? 0) : 0
        return Calendar.current.date(from: comps) ?? Date()
    }

    private static func string(from date: Date) -> String {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return String(format: "%02d:%02d", comps.hour ?? 0, comps.minute ?? 0)
    }
}
