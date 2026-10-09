import ScrechKit

final class Preferences: ObservableObject {
    @AppStorage("CRWantsMenuBarIcon") var wantsMenuBarIcon = true
    @AppStorage("CRWantsFloatingWindow") var wantsFloatingWindow = false

    @AppStorage("CRSidebar_ShowDefaultSimulator") var showDefaultSimulator = true
    @AppStorage("CRSidebar_ShowBootedDevicesFirst") var showBootedDevicesFirst = true
    @AppStorage("CRSidebar_ShowOnlyActiveDevices") var shouldShowOnlyActiveDevices = false

    @AppStorage("CRTerminalAppPath") var terminalAppPath = "/System/Applications/Utilities/Terminal.app"
}
