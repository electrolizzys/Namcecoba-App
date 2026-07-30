import Foundation
import Supabase

/// Owns the shared `SupabaseClient` for data-layer gateways.
enum SupabaseClientProvider {
    /// Backend project URL.
    private static let projectURL = URL(string: "https://cikpfliqixgkrydporpa.supabase.co")!

    /// Public (publishable) anon key. Safe to ship in the client.
    private static let publishableKey = "sb_publishable_ybR9eKUFIWhl1RlrCn3alQ_8To8zmR3"

    /// OAuth / email redirect target used for auth deep links.
    private static let redirectURL = URL(string: "https://electrolizzys.github.io/Namcecoba-App/")

    /// Process-wide Supabase client.
    static let client = SupabaseClient(
        supabaseURL: projectURL,
        supabaseKey: publishableKey,
        options: .init(auth: .init(redirectToURL: redirectURL))
    )
}
