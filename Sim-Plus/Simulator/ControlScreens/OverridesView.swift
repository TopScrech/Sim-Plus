import ScrechKit

struct OverridesView: View {
    let simulator: Simulator

    /// The system-wide appearance; "Light" or "Dark".
    @State private var appearance: SimCtl.UI.Appearance = .light

    /// The currently active language identifier
    @State private var language: String = NSLocale.current.language.languageCode?.identifier ?? ""

    /// The currently active locale identifier
    @State private var locale: String = NSLocale.current.identifier

    // The current Dynamic Type sizes
    @State private var contentSize: SimCtl.UI.ContentSizes = .medium

    @State private var enhanceTextLegibility = false
    @State private var showButtonShapes = false
    @State private var showOnOffLabels = false
    @State private var reduceTransparency = false
    @State private var increaseContrast = false
    @State private var differentiateWithoutColor = false
    @State private var smartInvert = false

    @State private var reduceMotion = false
    @State private var preferCrossFadeTransitions = false

    private let languages: [String] = {
        NSLocale.isoLanguageCodes
            .filter { NSLocale.current.localizedString(forLanguageCode: $0) != nil }
            .sorted { lhs, rhs in
                let lhsString = NSLocale.current.localizedString(forLanguageCode: lhs) ?? ""
                let rhsString = NSLocale.current.localizedString(forLanguageCode: rhs) ?? ""
                return lhsString.lowercased() < rhsString.lowercased()
            }
    }()

    var body: some View {
        Form {
            Section {
                Picker("Appearance", selection: $appearance.onChange(updateAppearance)) {
                    ForEach(SimCtl.UI.Appearance.allCases, id: \.self) {
                        Text($0.displayName)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Label("Appearance", systemImage: "circle.lefthalf.filled")
            }

            Section {
                Picker("Language", selection: $language.onChange(selectDefaultLocale)) {
                    ForEach(languages, id: \.self) {
                        Text(NSLocale.current.localizedString(forLanguageCode: $0) ?? "")
                    }
                }

                Picker("Region", selection: $locale) {
                    ForEach(locales(for: language), id: \.self) {
                        Text(NSLocale.current.localizedString(forIdentifier: $0) ?? "")
                    }
                }

                HStack {
                    Spacer()
                    Button("Apply & Reboot", action: updateLanguage)
                }
            } header: {
                Label("Language & Region", systemImage: "globe")
            } footer: {
                Text("Changing the language or region reboots the simulator.")
                    .caption()
                    .secondary()
            }

            Section {
                Picker("Text size", selection: $contentSize.onChange(updateContentSize)) {
                    ForEach(SimCtl.UI.ContentSizes.allCases, id: \.self) { size in
                        Text(size.rawValue)
                    }
                }

                Toggle("Bold Text", isOn: $enhanceTextLegibility.onChange(setEnhanceTextLegibility))
            } header: {
                Label("Text", systemImage: "textformat.size")
            }

            Section {
                Toggle("Button Shapes", isOn: $showButtonShapes.onChange(setShowButtonShapes))
                Toggle("On/Off Labels", isOn: $showOnOffLabels.onChange(setShowOnOffLabels))
                Toggle("Reduce Transparency", isOn: $reduceTransparency.onChange(setReduceTransparency))
                Toggle("Increase Contrast", isOn: $increaseContrast.onChange(setIncreaseContrast))
                Toggle("Differentiate Without Color", isOn: $differentiateWithoutColor.onChange(setDifferentiateWithoutColor))
                Toggle("Smart Invert", isOn: $smartInvert.onChange(setSmartInvert))
            } header: {
                Label("Display", systemImage: "accessibility")
            }

            Section {
                Toggle("Reduce Motion", isOn: $reduceMotion.onChange(setReduceMotion))

                Toggle("Prefer Cross-Fade Transitions", isOn: $preferCrossFadeTransitions.onChange(setPreferCrossFadeTransitions))
                    .disabled(reduceMotion == false)
            } header: {
                Label("Motion", systemImage: "figure.walk.motion")
            }
        }
        .formStyle(.grouped)
        .toggleStyle(.switch)
        .tabItem {
            Text("Overrides")
        }
    }

    /// Keeps the region valid when the language changes, falling back to the first region for that language.
    private func selectDefaultLocale() {
        let available = locales(for: language)

        if available.contains(locale) == false {
            locale = available.first ?? language
        }
    }

    /// Moves between light and dark mode.
    func updateAppearance() {
        SimCtl.setAppearance(simulator.udid, appearance: appearance)
    }

    func updateLanguage() {
        let plistPath = simulator.dataPath + "/Library/Preferences/.GlobalPreferences.plist"
        _ = Process.execute("/usr/bin/xcrun", arguments: ["plutil", "-replace", "AppleLanguages", "-json", "[\"\(language)\" ]", plistPath])
        _ = Process.execute("/usr/bin/xcrun", arguments: ["plutil", "-replace", "AppleLocale", "-string", locale, plistPath])
        SimCtl.reboot(simulator)
    }

    private func locales(for language: String) -> [String] {
        NSLocale.availableLocaleIdentifiers
            .filter { $0 == language || $0.hasPrefix(language + "_") }
            .sorted { (lhs, rhs) -> Bool in
                let lhsString = NSLocale.current.localizedString(forIdentifier: lhs) ?? ""
                let rhsString = NSLocale.current.localizedString(forIdentifier: rhs) ?? ""
                return lhsString.lowercased() < rhsString.lowercased()
            }
    }

    /// Update Content Size.
    func updateContentSize() {
        SimCtl.setContentSize(simulator.udid, contentSize: contentSize)
    }

    // Updates the simulator's accessibility setting for a particular key.
    // Example call: xcrun simctl spawn booted defaults write com.apple.Accessibility EnhancedTextLegibilityEnabled -bool FALSE
    func updateAccessibility(key: String, value: Bool) {
        _ = Process.execute("/usr/bin/xcrun", arguments: ["simctl", "spawn", simulator.id, "defaults", "write", "com.apple.Accessibility", key, "-bool", String(value)])
    }

    func setEnhanceTextLegibility() {
        updateAccessibility(key: "EnhancedTextLegibilityEnabled", value: enhanceTextLegibility)
    }

    func setShowButtonShapes() {
        updateAccessibility(key: "ButtonShapesEnabled", value: showButtonShapes)
    }

    func setShowOnOffLabels() {
        updateAccessibility(key: "IncreaseButtonLegibilityEnabled", value: showOnOffLabels)
    }

    func setReduceTransparency() {
        updateAccessibility(key: "EnhancedBackgroundContrastEnabled", value: reduceTransparency)
    }

    func setIncreaseContrast() {
        updateAccessibility(key: "DarkenSystemColors", value: increaseContrast)
    }

    func setDifferentiateWithoutColor() {
        updateAccessibility(key: "DifferentiateWithoutColor", value: differentiateWithoutColor)
    }

    func setSmartInvert() {
        updateAccessibility(key: "InvertColorsEnabled", value: smartInvert)
    }

    func setReduceMotion() {
        updateAccessibility(key: "ReduceMotionEnabled", value: reduceMotion)

        // Automatically disable the cross-fade animation if reduce motion is being
        // disabled. This matches what Settings does.
        if reduceMotion == false {
            preferCrossFadeTransitions = false
            updateAccessibility(key: "ReduceMotionReduceSlideTransitionsPreference", value: false)
        }
    }

    func setPreferCrossFadeTransitions() {
        updateAccessibility(key: "ReduceMotionReduceSlideTransitionsPreference", value: preferCrossFadeTransitions)
    }
}

struct OverridesView_Previews: PreviewProvider {
    static var previews: some View {
        OverridesView(simulator: .example)
            .environmentObject(Preferences())
    }
}
