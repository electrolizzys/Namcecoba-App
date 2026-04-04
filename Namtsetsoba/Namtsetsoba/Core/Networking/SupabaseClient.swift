import Supabase

let supabase = SupabaseClient(
    supabaseURL: NetworkEnvironment.supabaseURL,
    supabaseKey: NetworkEnvironment.supabaseAnonKey
)
