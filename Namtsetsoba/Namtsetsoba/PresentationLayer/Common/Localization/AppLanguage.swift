import Foundation

/// Languages the app can be displayed in. Georgian is the default.
enum AppLanguage: String, CaseIterable, Identifiable {
    case georgian = "ka"
    case english = "en"

    var id: String { rawValue }

    /// BCP-47 / ISO code used for `Locale`.
    var code: String { rawValue }

    /// Name shown in its own language (for the picker).
    var displayName: String {
        switch self {
        case .georgian: "ქართული"
        case .english: "English"
        }
    }

    /// Name in English (for debugging / secondary labels).
    var englishName: String {
        switch self {
        case .georgian: "Georgian"
        case .english: "English"
        }
    }

    var flag: String {
        switch self {
        case .georgian: "🇬🇪"
        case .english: "🇬🇧"
        }
    }
}
