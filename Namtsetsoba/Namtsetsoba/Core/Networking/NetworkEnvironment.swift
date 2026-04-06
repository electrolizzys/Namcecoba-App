import Foundation
import Supabase

enum NetworkEnvironment {
    static let supabaseURL = URL(string: "https://cikpfliqixgkrydporpa.supabase.co")!
    static let supabaseAnonKey = "sb_publishable_ybR9eKUFIWhl1RlrCn3alQ_8To8zmR3"

    static let supabase = SupabaseClient(
        supabaseURL: supabaseURL,
        supabaseKey: supabaseAnonKey
    )
}
