import Foundation

/// Keys for every user-facing string that supports localization.
///
/// New keys are added here and translated in `Translations`. Missing Georgian
/// values fall back to English, and a missing English value falls back to the
/// key name, so the app never shows a blank label.
enum L10n: String {
    // Tabs
    case tabOffers, tabStores, tabOrders, tabAlerts, tabProfile
    case tabMyProducts, tabAnalytics, tabDashboard, tabAddVenue

    // Common
    case commonSearch, commonSave, commonCancel, commonDone, commonCreate
    case commonSeeAll, commonNew, commonRetry, commonClose, commonLoading

    // Auth
    case authTagline, authSignIn, authRegister, authEmail, authPassword
    case authConfirmPassword, authUsername, authForgotPassword, authCreateAccount
    case authResetTitle, authResetSubtitle, authSendResetLink, authBackToSignIn
    case authRegisterConsent, authSigningOut

    // Profile
    case profileTitle, profileSettings, profileLanguage, profileChooseLanguage
    case profileSignOut, profileActivity, profileVenueAnalytics, profileMyImpact
    case profileAdminPanel

    // Offers / Home
    case offersTitle, offersSearchPlaceholder, offersEmptyTitle, offersEmptyMessage

    // Stores
    case storesTitle, storesSearchPlaceholder, storesEmptyTitle, storesEmptyMessage

    // Orders
    case ordersTitle, ordersSearchPlaceholder, ordersActive, ordersPast
    case ordersEmptyTitle, ordersEmptyMessage

    // Alerts / Notifications
    case alertsTitle, alertsSearchPlaceholder, alertsEmptyTitle, alertsEmptyMessage
}
