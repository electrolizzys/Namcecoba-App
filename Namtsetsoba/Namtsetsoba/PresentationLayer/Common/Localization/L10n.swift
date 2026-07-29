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
    case authLoginFailed, authRegisterFailed, authRegisterSuccess
    case authResetSuccess, authResetFailed
    case authEnterEmail, authEnterPassword, authEnterUsername
    case authPasswordTooShort, authPasswordsMismatch

    // Profile
    case profileTitle, profileSettings, profileLanguage, profileChooseLanguage
    case profileSignOut, profileActivity, profileVenueAnalytics, profileMyImpact
    case profileAdminPanel
    case profileSupport, profileHelpCenter, profileAbout, profileAccountSecurity
    case profileChangePassword, profileMyAccount
    case profileActiveBaskets, profileIncomingOrders, profileOrdersPlaced
    case profileFavoriteStores, profileStoreAppearance, profileStorePhotoHint
    case profileChooseStorePhoto, profileUploading, profileStorePhotoUpdated
    case profileCouldNotReadImage

    // Offers / Home
    case offersTitle, offersSearchPlaceholder, offersEmptyTitle, offersEmptyMessage

    // Stores
    case storesTitle, storesSearchPlaceholder, storesEmptyTitle, storesEmptyMessage

    // Orders
    case ordersTitle, ordersSearchPlaceholder, ordersActive, ordersPast
    case ordersEmptyTitle, ordersEmptyMessage

    // Alerts / Notifications
    case alertsTitle, alertsSearchPlaceholder, alertsEmptyTitle, alertsEmptyMessage
    case alertsFilterOrders, alertsFilterOffers, alertsFilterSupport, alertsReadAll
    case alertsJustNow, alertsMinutesAgo, alertsHoursAgo, alertsDaysAgo

    // Common (extra)
    case commonAll, commonPeriod, commonSend, commonMessage

    // Order status
    case statusConfirmed, statusReady, statusPickedUp, statusCancelled

    // User roles
    case roleCustomer, roleVenue, roleAdmin

    // Sort options
    case sortPrice, sortTopRated, sortDistance, sortFavorites, sortBestDeals
    case sortName, sortOpenNow, sortFavouritesLabel

    // Analytics periods
    case periodToday, periodWeek, periodMonth, periodAllTime
    case periodLastMonth, periodLastQuarter, periodLastYear

    // Order detail
    case orderDetailsTitle, orderConfirmPickup, orderConfirmPickupHint
    case orderConfirmPickupQuestion, orderConfirmPickupYes, orderConfirmPickupMessage
    case orderRatePrompt, orderRateStore, orderPickupCode, orderShowCodeCustomer
    case orderShowCodeStore, orderContentsStore, orderWhatYouOrdered, orderPickupLocation
    case orderOriginalPrice, orderYouSaved, orderAmountReceived, orderTotalPaid
    case orderMarkReady, orderMarkPickedUp, orderCancelOrder

    // Orders list
    case ordersIncomingTitle, ordersBusinessSearch, ordersActiveOrders, ordersPastOrders
    case ordersCustomerEmpty, ordersNoMatch, ordersStoreEmpty
    case ordersMarkAllReady, ordersMarkReadyOne, ordersPickupCodeLabel

    // Rating
    case rateTitle, rateNotNow, rateHowWas, rateCommentLabel, rateCommentPlaceholder
    case rateSubmit, rateSignInError

    // Analytics (customer)
    case analyticsYourImpact, analyticsMoneySaved, analyticsMoneySavedCaption
    case analyticsOrdersPlaced, analyticsBagsRescued, analyticsTotalSpent, analyticsAvgDiscount
    case analyticsGreenImpact, analyticsCO2Avoided, analyticsMealsKept
    case analyticsMostVisited, analyticsFavouriteStore

    // Analytics (venue)
    case venueYourIncome, venueIncomeCaption, venueBagsSold, venueActiveOrders
    case venueAvgOrderValue, venuePickupRate, venueRevenueBreakdown, venueGrossRevenue
    case venuePlatformFee, venueOrders, venuePickedUp, venueCancelled, venueAwaitingPickup
    case venueCustomers, venueUniqueCustomers, venueRepeatCustomers, venueCustomerRating
    case venueRatingsCount, venueEstimatedNoRatings, venueImpactCreated, venueMealsRescued
    case venueCustomerSavings

    // Admin
    case adminPanelTitle, adminOverview, adminCommerce, adminDirectory
    case adminStatistics, adminSalesByStore, adminRecentOrders, adminActiveOffers, adminUsers
    case adminNoStores, adminNoOffers, adminNoOrders, adminNoUsers, adminNoSales
    case adminSearchUsers, adminStatusFilter
    case adminRevenue, adminPickedUpOrders, adminCancelledOrders
    case adminCustomersWithPickup, adminMoneyPickedUp, adminPlatform10, adminStoreIncome, adminCancelRate
    case adminTotals, adminCommission10
    case adminOrderStatusBreakdown, adminAvgOrderValue, adminRepeat2plus, adminOffersLeft

    // Admin store form
    case formAddStoreTitle, formEditStoreTitle
    case formStorePhoto, formPhotoHint, formChoosePhoto, formChangePhoto
    case formStoreDetails, formName, formAddress
    case formLocation, formTapMap, formNoLocation
    case formOpeningHours, formOpens, formCloses
    case formVenueAccount, formTempPassword, formAccountHint
    case formCreateVenue, formVenueCreated

    // Change password
    case passwordTitle, passwordCurrent, passwordNew, passwordConfirm
    case passwordUpdate, passwordUpdated
    case passwordEnterCurrent, passwordTooShort, passwordMismatch
    case passwordMustDiffer, passwordMissingEmail, passwordChangeFailed
    case passwordHint

    // About
    case aboutTitle, aboutHero, aboutHowTitle, aboutHowBody
    case aboutWhereTitle, aboutWhereBody, aboutWhyTitle, aboutWhyBody
    case aboutVersionTitle, aboutVersionBody, aboutThanks

    // Help
    case helpTitle, helpNeedMore, helpCustomerContact, helpVenueContact
    case helpCustomerPickupTitle, helpCustomerPickupBody
    case helpCustomerPayTitle, helpCustomerPayBody
    case helpCustomerFavTitle, helpCustomerFavBody
    case helpCustomerVenuesTitle, helpCustomerVenuesBody
    case helpVenueAccountTitle, helpVenueAccountBody
    case helpVenueEditTitle, helpVenueEditBody
    case helpVenuePhotoTitle, helpVenuePhotoBody
    case helpVenueOrdersTitle, helpVenueOrdersBody
    case helpSupportTitle, helpSupportSubtitle, helpSupportPlaceholder
    case helpSupportSend, helpSupportSent, helpSupportFailed, helpSupportEmpty
}
