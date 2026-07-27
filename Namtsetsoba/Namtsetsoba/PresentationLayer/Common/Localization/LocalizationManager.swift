import Foundation
import Observation

/// Holds the user's preferred language and resolves localized strings.
///
/// Language changes take effect immediately: the root view keys its identity on
/// `language`, so flipping it rebuilds the view tree and every `L(...)` lookup is
/// re-evaluated — no app restart required.
@Observable
final class LocalizationManager {
    static let shared = LocalizationManager()

    private static let storageKey = "app.preferredLanguage"

    var language: AppLanguage {
        didSet {
            guard oldValue != language else { return }
            UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey)
        }
    }

    var locale: Locale { Locale(identifier: language.code) }

    private init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let saved = AppLanguage(rawValue: raw) {
            language = saved
        } else {
            language = .georgian
        }
    }

    func translation(for key: L10n) -> String {
        let table = language == .georgian ? Translations.ka : Translations.en
        return table[key] ?? Translations.en[key] ?? key.rawValue
    }
}

/// Global shorthand for a localized string in the current language.
func L(_ key: L10n) -> String {
    LocalizationManager.shared.translation(for: key)
}
