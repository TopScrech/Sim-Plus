import SwiftUI

// swiftlint:disable file_length
extension SimCtl {
    struct Command: CommandLineCommand {
        let arguments: [String]
        let environmentOverrides: [String: String]?

        private init(_ subcommand: String, arguments: [String], environmentOverrides: [String: String]? = nil) {
            self.arguments = ["simctl", subcommand] + arguments
            self.environmentOverrides = environmentOverrides
        }

        /// Create a new device
        static func create(name: String, deviceTypeId: String, runtimeId: String? = nil) -> Command {
            Command("create", arguments: [name, deviceTypeId])
        }
        /// Set logging
        static func setLogging(deviceTypeId: String, enableLogging: Bool) -> Command {
            Command("logverbose", arguments: [deviceTypeId, String(describing: enableLogging)])
        }
        /// Clone an existing device
        static func clone(deviceId: String, name: String) -> Command {
            Command("clone", arguments: [deviceId, name])
        }

        /// Delete spcified devices, unavailable devices, or all devices
        static func delete(_ delete: Delete) -> Command {
            Command("delete", arguments: delete.arguments)
        }

        /// Erase a device's contents and settings
        static func erase(_ erase: Erase) -> Command {
            Command("erase", arguments: erase.arguments)
        }

        /// Boot a device
        static func boot(simulator: Simulator) -> Command {
            if let buildVersion = simulator.runtime?.buildversion, buildVersion.compare("16.0", options: .numeric) == .orderedDescending {
                // Workaround to make status_bar overrides work for simulators > 16.1.
                // See https://federated.saagarjha.com/notice/AUwNsSsOOCWFc8qCvY.
                return Command("boot", arguments: [simulator.udid], environmentOverrides: ["SIMCTL_CHILD_SIMULATOR_RUNTIME_VERSION": "16.0"])
            } else {
                return Command("boot", arguments: [simulator.udid])
            }
        }

        /// Shutdown a device
        static func shutdown(_ shutdown: ShutDown) -> Command {
            Command("shutdown", arguments: shutdown.arguments)
        }

        /// Rename a device
        static func rename(deviceId: String, name: String) -> Command {
            Command("rename", arguments: [deviceId, name])
        }

        /// Open a URL in a device
        static func openURL(deviceId: String, url: String) -> Command {
            Command("openurl", arguments: [deviceId, url])
        }

        /// Add photos, live photos, videos, or contacts to the library of a device
        static func addMedia(deviceId: String, mediaPaths: [String]) -> Command {
            Command("addmedia", arguments: [deviceId] + mediaPaths)
        }

        /// Uninstall an app from a device
        static func uninstall(deviceId: String, appBundleId: String) -> Command {
            Command("uninstall", arguments: [deviceId, appBundleId])
        }

        /// Launch an application by identifier on a device
        static func launch(deviceId: String, appBundleId: String) -> Command {
            Command("launch", arguments: [deviceId, appBundleId])
        }

        /// Terminate an application by identifier on a device
        static func terminate(deviceId: String, appBundleId: String) -> Command {
            Command("terminate", arguments: [deviceId, appBundleId])
        }

        /// Spawn a process by executing a given executable on a device
        static func spawn(deviceId: String, pathToExecutable: String, options: [Spawn.Option] = []) -> Command {
            Command("spawn", arguments: options.flatMap(\.arguments) + [deviceId, pathToExecutable])
        }

        /// List available devices, device types, or runtimes
        static func list(filter: List.Filter? = nil, search: List.Search? = nil, flags: [List.Flag] = []) -> Command {
            var arguments: [String] = []

            if let filter {
                arguments.append(contentsOf: filter.arguments)
            }

            if let search {
                arguments.append(contentsOf: search.arguments)
            }

            return Command("list", arguments: arguments + flags.flatMap(\.arguments))
        }

        /// Show the installed applications
        static func listApps(deviceId: String, flags: [List.Flag] = []) -> Command {
            Command("listapps", arguments: [deviceId] + flags.flatMap(\.arguments))
        }

        /// Trigger iCloud sync on a device
        static func icloudSync(deviceId: String) -> Command {
            Command("icloud_sync", arguments: [deviceId])
        }

        /// Sync the pasteboard content from one pasteboard to another
        static func pbsync(source: Pasteboard.Device, destination: Pasteboard.Device) -> Command {
            Command("pbsync", arguments: source.arguments + destination.arguments)
        }

        /// Set up a device IO operation
        static func io(deviceId: String, operation: IO.Operation) -> Command {
            Command("io", arguments: [deviceId] + operation.arguments)
        }

        /// Set the user's current locaiton
        static func location(deviceId: String, latitude: Double, longitude: Double) -> Command {
            Command("location", arguments: [deviceId, "set", "\(latitude),\(longitude)"])
        }

        /// Set or clear status bar overrides
        static func statusBar(deviceId: String, operation: StatusBar.Operation) -> Command {
            Command("status_bar", arguments: [deviceId] + operation.arguments)
        }

        static func statusBarTime(deviceId: String, time: Date, timeZone: TimeZone = .current) -> Command {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.timeZone = timeZone
            // simctl requires milliseconds and a numeric offset, including +00:00 instead of Z
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSxxx"

            return statusBar(deviceId: deviceId, operation: .override([.time(formatter.string(from: time))]))
        }

        /// Get or Set UI options
        static func ui(deviceId: String, option: UI.Option) -> Command {
            Command("ui", arguments: [deviceId] + option.arguments)
        }

        /// Send a simulated push notification
        static func push(deviceId: String, appBundleId: String? = nil, json: Push.JSON) -> Command {
            var arguments: [String] = [deviceId]

            if let appBundleId {
                arguments.append(appBundleId)
            }

            return Command("push", arguments: arguments + json.arguments)
        }

        /// Grant, revoke, or reset privacy and permissi Manipulate a device's keychain
        static func privacy(deviceId: String, action: Privacy.Action, service: Privacy.Permission, appBundleId: String? = nil) -> Command {
            var arguments: [String] = [deviceId] + action.arguments + service.arguments

            if let appBundleId {
                arguments.append(appBundleId)
            }

            return Command("privacy", arguments: arguments)
        }

        /// Manipulate a device's keychain
        static func keychain(deviceId: String, action: Keychain.Action) -> Command {
            Command("keychain", arguments: [deviceId] + action.arguments)
        }
    }

    // swiftlint:disable nesting
    enum Delete {
        case devices([String]),
             unavailable

        var arguments: [String] {
            switch self {
            case .devices(let devices): devices
            case .unavailable: ["unavailable"]
            }
        }
    }

    enum Erase {
        case devices([String])

        var arguments: [String] {
            switch self {
            case .devices(let devices): devices
            }
        }
    }

    enum ShutDown {
        case devices([String])

        var arguments: [String] {
            switch self {
            case .devices(let devices): devices
            }
        }
    }

    enum Spawn {
        enum Option {
            case waitForDebugger

            var arguments: [String] {
                switch self {
                case .waitForDebugger: ["-w"]
                }
            }
        }
    }

    enum List {
        enum Filter: String {
            case devices, devicetypes, runtimes

            var arguments: [String] {
                [rawValue]
            }
        }

        enum Search {
            case string(String),
                 available

            var arguments: [String] {
                switch self {
                case .string(let string): [string]
                case .available: ["available"]
                }
            }
        }

        enum Flag: String {
            case json = "-j"

            var arguments: [String] {
                [rawValue]
            }
        }
    }

    enum Pasteboard {
        enum Device {
            case deviceId(String),
                 host

            var arguments: [String] {
                switch self {
                case .deviceId(let device): [device]
                case .host: ["host"]
                }
            }
        }

    }

    // swiftlint:disable type_name
    enum IO {
        // swiftlint:enable type_name
        enum Operation {
            case recordVideo(codec: Codec? = nil, display: Display? = nil, mask: Mask? = nil, force: Bool = false, url: String),
                 screenshot(type: ImageFormat? = nil, display: Display? = nil, mask: Mask? = nil, url: String)

            var arguments: [String] {
                switch self {
                case .recordVideo(let codec, let display, let mask, let force, let url):
                    var arguments = [String]()

                    if let codec {
                        arguments.append(contentsOf: codec.arguments)
                    }

                    if let display {
                        arguments.append(contentsOf: display.arguments)
                    }

                    if let mask {
                        arguments.append(contentsOf: mask.arguments)
                    }

                    return ["recordVideo"] + arguments + (force ? ["--force"] : []) + [url]
                case .screenshot(let type, let display, let mask, let url):
                    var arguments = [String]()

                    if let type {
                        arguments.append(contentsOf: type.arguments)
                    }

                    if let display {
                        arguments.append(contentsOf: display.arguments)
                    }

                    if let mask {
                        arguments.append(contentsOf: mask.arguments)
                    }

                    return ["screenshot"] + arguments + [url]
                }
            }
        }

        enum Codec: String {
            case h264

            var arguments: [String] {
                ["--codec=\(rawValue)"]
            }
        }

        enum Display: String, CaseIterable {
            case `internal`, external

            var arguments: [String] {
                ["--display=\(rawValue)"]
            }
        }

        enum Mask: String, CaseIterable {
            case ignored,
                 alpha,
                 black

            var arguments: [String] {
                ["--mask=\(rawValue)"]
            }
        }

        enum SaveLocation: RawRepresentable {
            case desktop,
                 other(URL)

            private var desktopURL: URL {
                FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0]
            }

            init(rawValue: String) {
                if rawValue != "Desktop", let url = URL(string: rawValue) {
                    self = .other(url)
                } else {
                    self = .desktop
                }
            }

            var rawValue: String {
                switch self {
                case .desktop: "Desktop"
                case .other(let url): url.absoluteString
                }
            }

            var url: URL {
                switch self {
                case .desktop:
                    return desktopURL
                case .other(let url):
                    return url
                }
            }
        }

        enum ImageFormat: String, CaseIterable {
            case png
            case jpeg
            case tiff
            case bmp

            var arguments: [String] {
                ["--type=\(rawValue)"]
            }

            var nsFileType: NSBitmapImageRep.FileType {
                switch self {
                case .png:
                    return .png
                case .jpeg:
                    return .jpeg
                case .tiff:
                    return .tiff
                case .bmp:
                    return .bmp
                }
            }
        }

        enum VideoFormat: String {
            case h264, h264Compressed, divider, smallGif, mediumGif, largeGif, fullGif

            static var all: [VideoFormat] {
                var options: [VideoFormat] = [.h264, .divider, .smallGif, .mediumGif, .largeGif, .fullGif]

                if FFMPEGConverter.available {
                    options.insert(.h264Compressed, at: 1)
                }

                return options
            }

            var name: String {
                switch self {
                case .h264:
                    return "H.264"
                case .h264Compressed:
                    return "H.264 (Compressed)"
                case .divider:
                    return ""
                case .smallGif:
                    return "GIF (Small)"
                case .mediumGif:
                    return "GIF (Medium)"
                case .largeGif:
                    return "GIF (Large)"
                case .fullGif:
                    return "GIF (Full)"
                }
            }
        }

    }

    enum StatusBar {
        enum Operation {
            case clear
            case override([Override])

            var arguments: [String] {
                switch self {
                case .clear:
                    return ["clear"]
                case .override(let overrides):
                    return ["override"] + overrides.flatMap(\.arguments)
                }
            }

            enum Override {
                case time(String)
                case dataNetwork(DataNetwork)
                case wifiMode(WifiMode)
                case wifiBars(WifiBars)
                case cellularMode(CellularMode)
                case cellularBars(CellularBars)
                case operatorName(String)
                case batteryState(BatteryState)
                case batteryLevel(Int)

                var arguments: [String] {
                    switch self {
                    case .time(let time):
                        return ["--time", time]
                    case .dataNetwork(let network):
                        return ["--dataNetwork", network.rawValue]
                    case .wifiMode(let mode):
                        return ["--wifiMode", mode.rawValue]
                    case .wifiBars(let bars):
                        return ["--wifiBars", "\(Int(bars.rawValue))"]
                    case .cellularMode(let mode):
                        return ["--cellularMode", mode.rawValue]
                    case .cellularBars(let bars):
                        return ["--cellularBars", "\(Int(bars.rawValue))"]
                    case .operatorName(let name):
                        return ["--operatorName", name]
                    case .batteryState(let state):
                        return ["--batteryState", state.rawValue]
                    case .batteryLevel(let level):
                        return ["--batteryLevel", "\(level)"]
                    }
                }
            }
        }

        enum DataNetwork: String, CaseIterable {
            case wifi = "wifi"
            case threeG = "3g"
            case fourG = "4g"
            case fiveG = "5g"
            case fiveGPlus = "5g+"
            case fiveGUWB = "5g-uwb"
            case lte = "lte"
            case lteA = "lte-a"
            case ltePlus = "lte+"
        }

        enum WifiMode: String, CaseIterable {
            case searching
            case failed
            case active
        }

        enum WifiBars: Int, CaseIterable {
            case zero
            case one
            case two
            case three

            var symbolVariable: Double {
                Double(self.rawValue) / Double(Self.allCases.count - 1)
            }
        }

        enum CellularMode: String, CaseIterable {
            case notSupported
            case searching
            case failed
            case active
        }

        enum CellularBars: Int, CaseIterable {
            case zero
            case one
            case two
            case three
            case four

            var symbolVariable: Double {
                Double(self.rawValue) / Double(Self.allCases.count - 1)
            }
        }

        enum BatteryState: String, CaseIterable {
            case charging
            case charged
            case discharging

            var displayName: String {
                rawValue.capitalized
            }
        }
    }

    // swiftlint:disable type_name
    public enum UI {
        // swiftlint:enable type_name
        enum Option {
            case appearance(Appearance)
            case contentSize(ContentSizes)

            var arguments: [String] {
                switch self {
                case .appearance(let appearance):
                    return ["appearance", appearance.rawValue]
                case .contentSize(let size):
                    switch size {
                    case .extraSmall:
                        return ["content_size", "extra-small"]
                    case .small:
                        return ["content_size", "small"]
                    case .medium:
                        return ["content_size", "medium"]
                    case .large:
                        return ["content_size", "large"]
                    case .extraLarge:
                        return ["content_size", "extra-large"]
                    case .extraExtraLarge:
                        return ["content_size", "extra-extra-large"]
                    case .extraExtraExtraLarge:
                        return ["content_size", "extra-extra-extra-large"]
                    case .accessibilityMedium:
                        return ["content_size", "accessibility-medium"]
                    case .accessibilityLarge:
                        return ["content_size", "accessibility-large"]
                    case .accessibilityExtraLarge:
                        return ["content_size", "accessibility-extra-large"]
                    case .accessibilityExtraExtraLarge:
                        return ["content_size", "accessibility-extra-extra-large"]
                    case .accessibilityExtraExtraExtraLarge:
                        return ["content_size", "accessibility-extra-extra-extra-large"]
                    }
                }
            }
        }

        enum Appearance: String, CaseIterable {
            case light
            case dark
        }
        enum ContentSizes: String, CaseIterable {
            case extraSmall = "Extra Small"
            case small = "Small"
            case medium = "Regular"
            case large = "Large"
            case extraLarge = "Extra Large"
            case extraExtraLarge = "Extra Extra Large"
            case extraExtraExtraLarge = "Extra Extra Extra Large"
            case accessibilityMedium = "Accessibility Medium"
            case accessibilityLarge = "Accessibility Large"
            case accessibilityExtraLarge = "Accessibility Extra Large"
            case accessibilityExtraExtraLarge = "Accessibility Extra Extra Large"
            case accessibilityExtraExtraExtraLarge = "Accessibility Extra Extra Extra Large"
        }
    }

    enum Push {
        enum JSON {
            case path(String)

            var arguments: [String] {
                switch self {
                case .path(let path):
                    return [path]
                }
            }
        }
    }

    enum Privacy {
        enum Action: String {
            case grant,
                 revoke,
                 reset

            var arguments: [String] {
                [rawValue]
            }
        }

        enum Permission: String, CaseIterable {
            case all,
                 calendar,
                 camera,
                 contactsLimited = "contacts-limited",
                 contacts,
                 location,
                 locationAlways = "location-always",
                 photosAdd,
                 photos,
                 mediaLibrary = "media-library",
                 microphone,
                 motion,
                 reminders,
                 siri

            var arguments: [String] {
                [rawValue]
            }
        }
    }

    enum Keychain {
        enum Action {
            case addRootCert(path: String),
                 reset

            var arguments: [String] {
                switch self {
                case .addRootCert(path: let path): ["add-root-cert", path]
                case .reset: ["reset"]
                }
            }
        }
    }

    // swiftlint:enable nesting
}
// swiftlint:enable file_length
