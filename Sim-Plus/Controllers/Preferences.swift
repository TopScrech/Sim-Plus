import ScrechKit

@Observable
final class Preferences {
    @ObservationIgnored
    @AppStorage("CRWantsMenuBarIcon") private var storedWantsMenuBarIcon = true

    @ObservationIgnored
    @AppStorage("CRWantsFloatingWindow") private var storedWantsFloatingWindow = false

    @ObservationIgnored
    @AppStorage("CRSidebar_ShowDefaultSimulator") private var storedShowDefaultSimulator = true

    @ObservationIgnored
    @AppStorage("CRSidebar_ShowBootedDevicesFirst") private var storedShowBootedDevicesFirst = true

    @ObservationIgnored
    @AppStorage("CRSidebar_ShowOnlyActiveDevices") private var storedShouldShowOnlyActiveDevices = false

    @ObservationIgnored
    @AppStorage("CRTerminalAppPath") private var storedTerminalAppPath = "/System/Applications/Utilities/Terminal.app"

    var wantsMenuBarIcon: Bool {
        get {
            access(keyPath: \.wantsMenuBarIcon)
            return storedWantsMenuBarIcon
        }
        set {
            withMutation(keyPath: \.wantsMenuBarIcon) {
                storedWantsMenuBarIcon = newValue
            }
        }
    }

    var wantsFloatingWindow: Bool {
        get {
            access(keyPath: \.wantsFloatingWindow)
            return storedWantsFloatingWindow
        }
        set {
            withMutation(keyPath: \.wantsFloatingWindow) {
                storedWantsFloatingWindow = newValue
            }
        }
    }

    var showDefaultSimulator: Bool {
        get {
            access(keyPath: \.showDefaultSimulator)
            return storedShowDefaultSimulator
        }
        set {
            withMutation(keyPath: \.showDefaultSimulator) {
                storedShowDefaultSimulator = newValue
            }
        }
    }

    var showBootedDevicesFirst: Bool {
        get {
            access(keyPath: \.showBootedDevicesFirst)
            return storedShowBootedDevicesFirst
        }
        set {
            withMutation(keyPath: \.showBootedDevicesFirst) {
                storedShowBootedDevicesFirst = newValue
            }
        }
    }

    var shouldShowOnlyActiveDevices: Bool {
        get {
            access(keyPath: \.shouldShowOnlyActiveDevices)
            return storedShouldShowOnlyActiveDevices
        }
        set {
            withMutation(keyPath: \.shouldShowOnlyActiveDevices) {
                storedShouldShowOnlyActiveDevices = newValue
            }
        }
    }

    var terminalAppPath: String {
        get {
            access(keyPath: \.terminalAppPath)
            return storedTerminalAppPath
        }
        set {
            withMutation(keyPath: \.terminalAppPath) {
                storedTerminalAppPath = newValue
            }
        }
    }
}
