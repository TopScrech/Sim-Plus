import Foundation

/// Actions that work on the last used simulator, app and URL.
/// Shared by the menu bar extra and the global keyboard shortcuts.
@MainActor
enum QuickActions {
    static let defaultPushPayload = """
    {
        "aps": {
            "alert": {
                "body": "Hello, World!",
                "title": "From Control Room"
            }
        }
    }
    """

    private static var defaults: UserDefaults { .standard }

    /// The simulator the quick actions target; falls back to whichever one simctl considers booted.
    static var lastSimulatorUDID: String {
        let udid = defaults.string(forKey: "CRLastSimulatorUDID") ?? ""
        return udid.isEmpty ? Simulator.default.udid : udid
    }

    private static var lastBundleID: String {
        defaults.string(forKey: "CRApps_LastBundleID") ?? ""
    }

    private static var lastOpenURL: String {
        defaults.string(forKey: "CRApps_LastOpenURL") ?? ""
    }

    private static var pushPayload: String {
        defaults.string(forKey: "CRApps_PushPayload") ?? defaultPushPayload
    }

    static var hasLastApp: Bool { lastBundleID.isEmpty == false }
    static var hasLastURL: Bool { lastOpenURL.isEmpty == false }

    static func resendLastPushNotification() {
        guard hasLastApp else { return }
        SimCtl.sendPushNotification(lastSimulatorUDID, appID: lastBundleID, jsonPayload: pushPayload)
    }

    static func restartLastSelectedApp() {
        guard hasLastApp else { return }
        SimCtl.restart(lastSimulatorUDID, appID: lastBundleID)
    }

    static func reopenLastURL() {
        guard hasLastURL else { return }
        SimCtl.openURL(lastSimulatorUDID, URL: lastOpenURL)
    }

    static func open(_ link: DeepLink) {
        SimCtl.openURL(lastSimulatorUDID, URL: link.url.absoluteString)
    }
}
