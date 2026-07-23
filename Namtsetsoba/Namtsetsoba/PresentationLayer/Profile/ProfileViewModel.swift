import Foundation
import Observation

/// Presentation logic for profile: store logo, favourites, account edits.
@Observable
final class ProfileViewModel {
    @ObservationIgnored private let uploadStoreLogoUseCase: UploadStoreLogoUseCase
    @ObservationIgnored private let fetchBusinessBasketsUseCase: FetchBusinessBasketsUseCase
    @ObservationIgnored private let fetchStoresUseCase: FetchStoresUseCase
    @ObservationIgnored private let updateUsernameUseCase: UpdateUsernameUseCase
    @ObservationIgnored private let changePasswordUseCase: ChangePasswordUseCase

    init(container: AppContainer = .shared) {
        uploadStoreLogoUseCase = container.uploadStoreLogo
        fetchBusinessBasketsUseCase = container.fetchBusinessBaskets
        fetchStoresUseCase = container.fetchStores
        updateUsernameUseCase = container.updateUsername
        changePasswordUseCase = container.changePassword
    }

    /// Uploads a new store logo and returns the refreshed store plus its baskets.
    func uploadLogo(storeId: UUID, jpegData: Data) async throws -> (store: Store?, baskets: [Basket]) {
        let store = try await uploadStoreLogoUseCase.execute(storeId: storeId, jpegData: jpegData)
        let baskets = (try? await fetchBusinessBasketsUseCase.execute(storeId: storeId)) ?? []
        return (store, baskets)
    }

    func loadStores() async -> [Store] {
        (try? await fetchStoresUseCase.execute()) ?? []
    }

    func updateUsername(_ username: String) async throws {
        try await updateUsernameUseCase.execute(username: username)
    }

    func changePassword(email: String, currentPassword: String, newPassword: String) async throws {
        try await changePasswordUseCase.execute(
            email: email,
            currentPassword: currentPassword,
            newPassword: newPassword
        )
    }
}
