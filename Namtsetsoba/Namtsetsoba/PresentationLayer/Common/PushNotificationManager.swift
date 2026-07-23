import Foundation
import UIKit
import UserNotifications

@Observable
final class PushNotificationManager: NSObject {
    static let shared = PushNotificationManager()

    /// Set when user taps a push; consumed by ContentView / MainTabView.
    private(set) var pendingOrderId: UUID?

    private var lastRegisteredToken: String?

    private override init() {
        super.init()
    }

    func configure() {
        UNUserNotificationCenter.current().delegate = self
    }

    @MainActor
    func requestAuthorizationAndRegister() async {
        configure()

        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            guard granted else {
                print("ℹ️ Push permission not granted")
                return
            }
            UIApplication.shared.registerForRemoteNotifications()
        } catch {
            print("⚠️ Push permission request failed: \(error.localizedDescription)")
        }
    }

    func handleDeviceToken(_ deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        lastRegisteredToken = token
        print("ℹ️ APNs device token: \(token)")

        Task { @MainActor in
            guard let user = try? await AppContainer.shared.getCurrentUser.execute() else { return }
            try? await AppContainer.shared.registerDeviceToken.execute(userId: user.id, token: token)
        }
    }

    func handleRegistrationFailure(_ error: Error) {
        print("⚠️ APNs registration failed: \(error.localizedDescription)")
    }

    @MainActor
    func applyPendingNavigation(appState: AppState, tabSelection: MainTabSelection?) {
        guard let orderId = pendingOrderId else { return }
        appState.queueOrderNavigation(to: orderId)
        tabSelection?.openOrders(isBusiness: appState.currentRole == .business)
        pendingOrderId = nil
    }

    @MainActor
    func clearTokenOnSignOut() async {
        guard let user = try? await AppContainer.shared.getCurrentUser.execute(),
              let token = lastRegisteredToken else { return }
        try? await AppContainer.shared.removeDeviceToken.execute(userId: user.id, token: token)
        lastRegisteredToken = nil
    }

    func handleLaunchNotification(_ userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String,
              type == "order",
              let referenceIdString = userInfo["reference_id"] as? String,
              let orderId = UUID(uuidString: referenceIdString) else { return }
        pendingOrderId = orderId
    }

    private func handleNotificationPayload(_ userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String,
              type == "order",
              let referenceIdString = userInfo["reference_id"] as? String,
              let orderId = UUID(uuidString: referenceIdString) else { return }

        Task { @MainActor in
            pendingOrderId = orderId
            NotificationCenter.default.post(name: .pushNotificationTapped, object: nil)
        }
    }
}

extension PushNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        handleNotificationPayload(response.notification.request.content.userInfo)
    }
}

extension Notification.Name {
    static let pushNotificationTapped = Notification.Name("pushNotificationTapped")
}
