import ScrechKit

/// Controls WiFi and cellular data state for the whole device.
struct StatusBarView: View {
    let simulator: Simulator

    /// The current time to show in the device.
    @State private var time = Date.now

    /// The active data network; can be one of "WiFi", "3G", "4G", "5G", "5G+", "5G-UWB", "LTE", "LTE-A", or "LTE+".
    @State private var dataNetwork: SimCtl.StatusBar.DataNetwork = .wifi

    /// Whether WiFi is currently active; can be "Active", "Searching", or "Failed".
    @State private var wiFiMode: SimCtl.StatusBar.WifiMode = .active

    /// How many WiFi bars the device is showing, as a range from 0 through 3.
    @State private var wiFiBar: SimCtl.StatusBar.WifiBars = .three

    /// Whether cellular data is currently active; can be "Active", "Searching", "Failed", or "Not Supported".
    @State private var cellularMode: SimCtl.StatusBar.CellularMode = .active

    /// How many cellular bars the device is showing, as a range from 0 through 4.
    @State private var cellularBar: SimCtl.StatusBar.CellularBars = .four

    @AppStorage("CRNetwork_CarrierName") private var carrierName = "Carrier"

    /// The current battery level of the device, as a value from 0 through 100
    @State private var batteryLevel = 100.0

    /// The current battery state of the device; must be "Charging", "Charged", or "Discharging"
    @State private var batteryState: SimCtl.StatusBar.BatteryState = .charged

    var body: some View {
        Form {
            Section {
                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)

                HStack {
                    Spacer()
                    Button("Set to 9:41", action: setAppleTime)
                    Button("Apply", action: setTime)
                        .keyboardShortcut(.defaultAction)
                }
            } header: {
                Label("Time", systemImage: "clock")
            }

            Section {
                TextField("Operator", text: $carrierName)
                    .onSubmit(updateCellularData)

                Picker("Network type", selection: $dataNetwork.onChange(updateWiFiData)) {
                    ForEach(SimCtl.StatusBar.DataNetwork.allCases, id: \.self) { network in
                        Text(network.displayName)
                    }
                }
            } header: {
                Label("Network", systemImage: "antenna.radiowaves.left.and.right")
            }

            Section {
                Picker("Mode", selection: $wiFiMode.onChange(updateWiFiData)) {
                    ForEach(SimCtl.StatusBar.WifiMode.allCases, id: \.self) { mode in
                        Text(mode.displayName)
                    }
                }

                Picker("Signal", selection: $wiFiBar.onChange(updateWiFiData)) {
                    ForEach(SimCtl.StatusBar.WifiBars.allCases, id: \.self) { bars in
                        Image(systemName: "wifi", variableValue: bars.symbolVariable)
                            .help("\(bars.rawValue) of \(SimCtl.StatusBar.WifiBars.allCases.count - 1) bars")
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Label("Wi-Fi", systemImage: "wifi")
            } footer: {
                if dataNetwork != .wifi {
                    Text("Wi-Fi is only shown when the network type is Wi-Fi.")
                        .caption()
                        .secondary()
                }
            }
            .disabled(dataNetwork != .wifi)

            Section {
                Picker("Mode", selection: $cellularMode.onChange(updateCellularData)) {
                    ForEach(SimCtl.StatusBar.CellularMode.allCases, id: \.self) { mode in
                        Text(mode.displayName)
                    }
                }

                Picker("Signal", selection: $cellularBar.onChange(updateCellularData)) {
                    ForEach(SimCtl.StatusBar.CellularBars.allCases, id: \.self) { bars in
                        Image(systemName: "cellularbars", variableValue: bars.symbolVariable)
                            .help("\(bars.rawValue) of \(SimCtl.StatusBar.CellularBars.allCases.count - 1) bars")
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Label("Cellular", systemImage: "cellularbars")
            }

            Section {
                Picker("State", selection: $batteryState.onChange(updateBattery)) {
                    ForEach(SimCtl.StatusBar.BatteryState.allCases, id: \.self) { state in
                        Text(state.displayName)
                    }
                }
                .pickerStyle(.segmented)

                LabeledContent("Level") {
                    HStack {
                        Slider(value: $batteryLevel, in: 0...100, step: 1, onEditingChanged: levelChanged)

                        Text("\(Int(batteryLevel))%")
                            .monospacedDigit()
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            } header: {
                Label("Battery", systemImage: batterySymbol)
            }

            Section {
                HStack {
                    Spacer()
                    Button("Clear Overrides", role: .destructive, action: clearOverrides)
                }
            }
        }
        .formStyle(.grouped)
        .tabItem {
            Text("Status Bar")
        }
    }

    /// An SF Symbol reflecting the selected battery level and state.
    private var batterySymbol: String {
        let percent = switch batteryLevel {
        case ..<13: 0
        case ..<38: 25
        case ..<63: 50
        case ..<88: 75
        default: 100
        }

        return batteryState == .charging && percent == 100 ? "battery.100percent.bolt" : "battery.\(percent)percent"
    }

    // MARK: Private methods

    /// Changes the system clock to a new value.
    private func setTime() {
        SimCtl.overrideStatusBarTime(simulator.udid, time: time)
    }

    private func setAppleTime() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date.now)
        components.hour = 9
        components.minute = 41
        components.second = 0

        let appleTime = calendar.date(from: components) ?? Date.now
        SimCtl.overrideStatusBarTime(simulator.udid, time: appleTime)

        time = appleTime
    }

    private func clearOverrides() {
        SimCtl.clearStatusBarOverrides(simulator.udid)
        time = .now
        dataNetwork = .wifi
        wiFiMode = .active
        wiFiBar = .three
        cellularMode = .active
        cellularBar = .four
        batteryLevel = 100.0
        batteryState = .charged
        carrierName = "Carrier"
    }

    /// Sends status bar updates all at once; simctl gets unhappy if we send them individually, but
    /// also for whatever reason prefers cellular data sent separately from WiFi.
    private func updateWiFiData() {
        SimCtl.overrideStatusBarWiFi(
            simulator.udid,
            network: dataNetwork,
            wifiMode: wiFiMode,
            wifiBars: wiFiBar
        )
    }

    private func updateCellularData() {
        SimCtl.overrideStatusBarCellular(
            simulator.udid,
            cellMode: cellularMode,
            cellBars: cellularBar,
            carrier: carrierName
        )
    }

    /// Sends battery updates all at once; simctl gets unhappy if we send them individually.
    private func updateBattery() {
        SimCtl.overrideStatusBarBattery(
            simulator.udid,
            level: Int(batteryLevel),
            state: batteryState
        )
    }

    /// Triggered when the user adjusts the battery level.
    private func levelChanged(_ isEditing: Bool) {
        if isEditing == false {
            updateBattery()
        }
    }
}

// MARK: Preview

struct StatusBarViewView_Previews: PreviewProvider {
    static var previews: some View {
        StatusBarView(simulator: .example)
            .environmentObject(Preferences())
    }
}

// MARK: Extensions

extension SimCtl.StatusBar.DataNetwork {
    var displayName: String {
        switch self {
        case .wifi:
            return "Wi-Fi"
        default:
            return rawValue.uppercased()
        }
    }
}

extension SimCtl.StatusBar.WifiMode {
    var displayName: String {
        rawValue.capitalized
    }
}

extension SimCtl.StatusBar.CellularMode {
    var displayName: String {
        switch self {
        case .notSupported:
            return "Not Supported"
        default:
            return rawValue.capitalized
        }
    }
}
