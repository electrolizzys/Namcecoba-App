import Foundation

/// Composition root.
///
/// Builds the single graph of data-layer gateways and exposes ready-to-use
/// use cases to the presentation layer. View models resolve their dependencies
/// from `AppContainer.shared` by default, but every use case can be injected
/// explicitly in tests.
final class AppContainer {
    static let shared = AppContainer()

    // MARK: - Gateways (data layer)

    let authGateway: AuthGateway
    let profileGateway: ProfileGateway
    let storeGateway: StoreGateway
    let basketGateway: BasketGateway
    let orderGateway: OrderGateway
    let notificationGateway: NotificationGateway
    let favouriteGateway: FavouriteGateway
    let deviceTokenGateway: DeviceTokenGateway
    let adminGateway: AdminGateway
    let ratingGateway: RatingGateway

    init(
        authGateway: AuthGateway = ApiAuthGateway(),
        profileGateway: ProfileGateway = ApiProfileGateway(),
        storeGateway: StoreGateway = ApiStoreGateway(),
        basketGateway: BasketGateway = ApiBasketGateway(),
        notificationGateway: NotificationGateway = ApiNotificationGateway(),
        favouriteGateway: FavouriteGateway = ApiFavouriteGateway(),
        deviceTokenGateway: DeviceTokenGateway = ApiDeviceTokenGateway(),
        adminGateway: AdminGateway? = nil,
        ratingGateway: RatingGateway = ApiRatingGateway()
    ) {
        self.authGateway = authGateway
        self.profileGateway = profileGateway
        self.storeGateway = storeGateway
        self.basketGateway = basketGateway
        self.orderGateway = ApiOrderGateway(basketGateway: basketGateway)
        self.notificationGateway = notificationGateway
        self.favouriteGateway = favouriteGateway
        self.deviceTokenGateway = deviceTokenGateway
        self.adminGateway = adminGateway ?? ApiAdminGateway(basketGateway: basketGateway)
        self.ratingGateway = ratingGateway
    }

    // MARK: - Auth use cases

    var signIn: SignInUseCase { SignInUseCaseImpl(gateway: authGateway) }
    var signUp: SignUpUseCase { SignUpUseCaseImpl(gateway: authGateway) }
    var sendPasswordReset: SendPasswordResetUseCase { SendPasswordResetUseCaseImpl(gateway: authGateway) }
    var signOut: SignOutUseCase { SignOutUseCaseImpl(gateway: authGateway) }
    var getCurrentUser: GetCurrentUserUseCase { GetCurrentUserUseCaseImpl(gateway: authGateway) }
    var updateUsername: UpdateUsernameUseCase { UpdateUsernameUseCaseImpl(gateway: authGateway) }
    var changePassword: ChangePasswordUseCase { ChangePasswordUseCaseImpl(gateway: authGateway) }

    // MARK: - Profile use cases

    var loadUserProfile: LoadUserProfileUseCase {
        LoadUserProfileUseCaseImpl(authGateway: authGateway, profileGateway: profileGateway)
    }

    // MARK: - Store use cases

    var fetchStores: FetchStoresUseCase { FetchStoresUseCaseImpl(gateway: storeGateway) }
    var fetchStore: FetchStoreUseCase { FetchStoreUseCaseImpl(gateway: storeGateway) }
    var uploadStoreLogo: UploadStoreLogoUseCase { UploadStoreLogoUseCaseImpl(gateway: storeGateway) }

    // MARK: - Basket use cases

    var fetchAvailableBaskets: FetchAvailableBasketsUseCase { FetchAvailableBasketsUseCaseImpl(gateway: basketGateway) }
    var fetchBusinessBaskets: FetchBusinessBasketsUseCase { FetchBusinessBasketsUseCaseImpl(gateway: basketGateway) }
    var createBasket: CreateBasketUseCase { CreateBasketUseCaseImpl(gateway: basketGateway) }
    var updateBasket: UpdateBasketUseCase { UpdateBasketUseCaseImpl(gateway: basketGateway) }
    var deleteBasket: DeleteBasketUseCase { DeleteBasketUseCaseImpl(gateway: basketGateway) }

    // MARK: - Order use cases

    var placeOrder: PlaceOrderUseCase { PlaceOrderUseCaseImpl(orderGateway: orderGateway, basketGateway: basketGateway) }
    var fetchOrders: FetchOrdersUseCase { FetchOrdersUseCaseImpl(gateway: orderGateway) }
    var fetchStoreOrders: FetchStoreOrdersUseCase { FetchStoreOrdersUseCaseImpl(gateway: orderGateway) }
    var updateOrderStatus: UpdateOrderStatusUseCase { UpdateOrderStatusUseCaseImpl(gateway: orderGateway) }

    // MARK: - Notification use cases

    var fetchNotifications: FetchNotificationsUseCase { FetchNotificationsUseCaseImpl(gateway: notificationGateway) }
    var markNotificationAsRead: MarkNotificationAsReadUseCase { MarkNotificationAsReadUseCaseImpl(gateway: notificationGateway) }
    var markAllNotificationsAsRead: MarkAllNotificationsAsReadUseCase { MarkAllNotificationsAsReadUseCaseImpl(gateway: notificationGateway) }

    // MARK: - Favourite use cases

    var fetchFavouriteStoreIds: FetchFavouriteStoreIdsUseCase { FetchFavouriteStoreIdsUseCaseImpl(gateway: favouriteGateway) }
    var addFavouriteStore: AddFavouriteStoreUseCase { AddFavouriteStoreUseCaseImpl(gateway: favouriteGateway) }
    var removeFavouriteStore: RemoveFavouriteStoreUseCase { RemoveFavouriteStoreUseCaseImpl(gateway: favouriteGateway) }

    // MARK: - Device token use cases

    var registerDeviceToken: RegisterDeviceTokenUseCase { RegisterDeviceTokenUseCaseImpl(gateway: deviceTokenGateway) }
    var removeDeviceToken: RemoveDeviceTokenUseCase { RemoveDeviceTokenUseCaseImpl(gateway: deviceTokenGateway) }

    // MARK: - Rating use cases

    var submitRating: SubmitRatingUseCase { SubmitRatingUseCaseImpl(gateway: ratingGateway) }
    var fetchRatedOrderIds: FetchRatedOrderIdsUseCase { FetchRatedOrderIdsUseCaseImpl(gateway: ratingGateway) }
    var fetchStoreRatings: FetchStoreRatingsUseCase { FetchStoreRatingsUseCaseImpl(gateway: ratingGateway) }

    // MARK: - Analytics use cases

    var computeVenueAnalytics: ComputeVenueAnalyticsUseCase { ComputeVenueAnalyticsUseCaseImpl() }
    var computeCustomerAnalytics: ComputeCustomerAnalyticsUseCase { ComputeCustomerAnalyticsUseCaseImpl() }

    // MARK: - Admin use cases

    var fetchAdminDashboard: FetchAdminDashboardUseCase {
        FetchAdminDashboardUseCaseImpl(gateway: adminGateway)
    }
    var fetchStoreSales: FetchStoreSalesUseCase {
        FetchStoreSalesUseCaseImpl(gateway: adminGateway)
    }
    var fetchAdminOrders: FetchAdminOrdersUseCase {
        FetchAdminOrdersUseCaseImpl(gateway: adminGateway)
    }
    var fetchAdminUsers: FetchAdminUsersUseCase {
        FetchAdminUsersUseCaseImpl(gateway: adminGateway)
    }
    var fetchAdminOffers: FetchAdminOffersUseCase {
        FetchAdminOffersUseCaseImpl(gateway: adminGateway)
    }
    var fetchAdminAnalytics: FetchAdminAnalyticsUseCase {
        FetchAdminAnalyticsUseCaseImpl(gateway: adminGateway)
    }
    var createStoreWithVenue: CreateStoreWithVenueUseCase {
        CreateStoreWithVenueUseCaseImpl(gateway: adminGateway)
    }
    var updateStore: UpdateStoreUseCase {
        UpdateStoreUseCaseImpl(gateway: adminGateway)
    }
}
