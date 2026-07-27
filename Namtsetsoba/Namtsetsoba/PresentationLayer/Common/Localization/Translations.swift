import Foundation

/// Static translation tables. English is the reference; Georgian is the default
/// shown to users.
enum Translations {
    static let en: [L10n: String] = [
        // Tabs
        .tabOffers: "Offers",
        .tabStores: "Stores",
        .tabOrders: "Orders",
        .tabAlerts: "Alerts",
        .tabProfile: "Profile",
        .tabMyProducts: "My Products",
        .tabAnalytics: "Analytics",
        .tabDashboard: "Dashboard",
        .tabAddVenue: "Add Venue",

        // Common
        .commonSearch: "Search",
        .commonSave: "Save",
        .commonCancel: "Cancel",
        .commonDone: "Done",
        .commonCreate: "Create",
        .commonSeeAll: "See all",
        .commonNew: "New",
        .commonRetry: "Retry",
        .commonClose: "Close",
        .commonLoading: "Loading…",

        // Auth
        .authTagline: "Rescue great food. Save money. Waste less.",
        .authSignIn: "Sign In",
        .authRegister: "Register",
        .authEmail: "Email",
        .authPassword: "Password",
        .authConfirmPassword: "Confirm password",
        .authUsername: "Username",
        .authForgotPassword: "Forgot password?",
        .authCreateAccount: "Create Account",
        .authResetTitle: "Reset password",
        .authResetSubtitle: "Enter your email and we'll send you a secure reset link.",
        .authSendResetLink: "Send Reset Link",
        .authBackToSignIn: "Back to Sign In",
        .authRegisterConsent: "By registering you agree to rescue food responsibly. 🌱",
        .authSigningOut: "Signing out…",

        // Profile
        .profileTitle: "Profile",
        .profileSettings: "Settings",
        .profileLanguage: "Language",
        .profileChooseLanguage: "Choose language",
        .profileSignOut: "Sign Out",
        .profileActivity: "Activity",
        .profileVenueAnalytics: "Sales & Analytics",
        .profileMyImpact: "My Impact",
        .profileAdminPanel: "Admin Panel",

        // Offers
        .offersTitle: "Offers",
        .offersSearchPlaceholder: "Search offers or stores",
        .offersEmptyTitle: "No offers found",
        .offersEmptyMessage: "Try adjusting your filters or check back soon.",

        // Stores
        .storesTitle: "Stores",
        .storesSearchPlaceholder: "Search stores",
        .storesEmptyTitle: "No stores found",
        .storesEmptyMessage: "Try a different search or category.",

        // Orders
        .ordersTitle: "Orders",
        .ordersSearchPlaceholder: "Search by store",
        .ordersActive: "Active",
        .ordersPast: "Past",
        .ordersEmptyTitle: "No orders yet",
        .ordersEmptyMessage: "Your reserved bags will appear here.",

        // Alerts
        .alertsTitle: "Alerts",
        .alertsSearchPlaceholder: "Search notifications",
        .alertsEmptyTitle: "No notifications",
        .alertsEmptyMessage: "You're all caught up.",
    ]

    static let ka: [L10n: String] = [
        // Tabs
        .tabOffers: "შეთავაზებები",
        .tabStores: "მაღაზიები",
        .tabOrders: "შეკვეთები",
        .tabAlerts: "შეტყობინებები",
        .tabProfile: "პროფილი",
        .tabMyProducts: "ჩემი პროდუქტები",
        .tabAnalytics: "ანალიტიკა",
        .tabDashboard: "ანალიტიკა",
        .tabAddVenue: "მაღაზიის დამატება",

        // Common
        .commonSearch: "ძებნა",
        .commonSave: "შენახვა",
        .commonCancel: "გაუქმება",
        .commonDone: "მზადაა",
        .commonCreate: "შექმნა",
        .commonSeeAll: "ყველას ნახვა",
        .commonNew: "ახალი",
        .commonRetry: "ხელახლა ცდა",
        .commonClose: "დახურვა",
        .commonLoading: "იტვირთება…",

        // Auth
        .authTagline: "გადაარჩინე საკვები. დაზოგე ფული. ნაკლები ნარჩენი.",
        .authSignIn: "შესვლა",
        .authRegister: "რეგისტრაცია",
        .authEmail: "ელფოსტა",
        .authPassword: "პაროლი",
        .authConfirmPassword: "გაიმეორეთ პაროლი",
        .authUsername: "მომხმარებლის სახელი",
        .authForgotPassword: "დაგავიწყდათ პაროლი?",
        .authCreateAccount: "ანგარიშის შექმნა",
        .authResetTitle: "პაროლის აღდგენა",
        .authResetSubtitle: "შეიყვანეთ ელფოსტა და გამოგიგზავნით აღდგენის ბმულს.",
        .authSendResetLink: "ბმულის გაგზავნა",
        .authBackToSignIn: "შესვლაზე დაბრუნება",
        .authRegisterConsent: "რეგისტრაციით თქვენ ეთანხმებით საკვების პასუხისმგებლიან გადარჩენას. 🌱",
        .authSigningOut: "გამოსვლა…",

        // Profile
        .profileTitle: "პროფილი",
        .profileSettings: "პარამეტრები",
        .profileLanguage: "ენა",
        .profileChooseLanguage: "აირჩიეთ ენა",
        .profileSignOut: "გასვლა",
        .profileActivity: "აქტივობა",
        .profileVenueAnalytics: "გაყიდვები და ანალიტიკა",
        .profileMyImpact: "ჩემი წვლილი",
        .profileAdminPanel: "ადმინ პანელი",

        // Offers
        .offersTitle: "შეთავაზებები",
        .offersSearchPlaceholder: "მოძებნეთ შეთავაზება ან მაღაზია",
        .offersEmptyTitle: "შეთავაზებები ვერ მოიძებნა",
        .offersEmptyMessage: "შეცვალეთ ფილტრები ან შეამოწმეთ მოგვიანებით.",

        // Stores
        .storesTitle: "მაღაზიები",
        .storesSearchPlaceholder: "მოძებნეთ მაღაზია",
        .storesEmptyTitle: "მაღაზიები ვერ მოიძებნა",
        .storesEmptyMessage: "სცადეთ სხვა ძებნა ან კატეგორია.",

        // Orders
        .ordersTitle: "შეკვეთები",
        .ordersSearchPlaceholder: "ძებნა მაღაზიით",
        .ordersActive: "აქტიური",
        .ordersPast: "წარსული",
        .ordersEmptyTitle: "შეკვეთები ჯერ არ არის",
        .ordersEmptyMessage: "თქვენი დაჯავშნილი პაკეტები აქ გამოჩნდება.",

        // Alerts
        .alertsTitle: "შეტყობინებები",
        .alertsSearchPlaceholder: "მოძებნეთ შეტყობინება",
        .alertsEmptyTitle: "შეტყობინებები არ არის",
        .alertsEmptyMessage: "ყველაფერი ნანახია.",
    ]
}
