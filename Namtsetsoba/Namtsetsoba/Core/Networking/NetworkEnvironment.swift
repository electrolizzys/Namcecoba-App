import Foundation
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://cikpfliqixgkrydporpa.supabase.co")!,
    supabaseKey: "sb_publishable_ybR9eKUFIWhl1RlrCn3alQ_8To8zmR3",
    options: .init(auth: .init(redirectToURL: URL(string: "https://electrolizzys.github.io/Namcecoba-App/")))
)
