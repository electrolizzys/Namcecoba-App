import Foundation

/// Payload for creating a store and its venue login in one admin action.
struct NewVenueOnboarding: Hashable {
    var store: StoreEdit
    var accountEmail: String
    var temporaryPassword: String
    var accountUsername: String
}
