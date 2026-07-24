import Foundation
import Observation

@Observable
final class AdminUsersViewModel {
    var users: [UserProfile] = []
    var searchText = ""
    var isLoading = false
    var errorMessage: String?

    @ObservationIgnored private let fetchUsers: FetchAdminUsersUseCase

    init(container: AppContainer = .shared) {
        fetchUsers = container.fetchAdminUsers
    }

    var filteredUsers: [UserProfile] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return users }
        return users.filter {
            $0.email.localizedCaseInsensitiveContains(q) ||
            $0.username.localizedCaseInsensitiveContains(q) ||
            $0.id.uuidString.localizedCaseInsensitiveContains(q)
        }
    }

    @MainActor
    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            users = try await fetchUsers.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
