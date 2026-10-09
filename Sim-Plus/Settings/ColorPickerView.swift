import ScrechKit

struct ColorPickerView: View {
    /// Whether hex strings should be printed in uppercase or not.
    @AppStorage("CRColorPickerUppercaseHex") var uppercaseHex = true

    /// How many decimal places to use for rounding picked colors.
    @AppStorage("CRColorPickerAccuracy") var colorPickerAccuracy = 2

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $uppercaseHex) {
                    Text("Uppercase hex strings")
                    Text(uppercaseHex ? "#FF9F0A" : "#ff9f0a")
                        .monospaced()
                }

                Stepper(value: $colorPickerAccuracy, in: 0...5) {
                    Text("Decimal places: \(colorPickerAccuracy)")
                        .monospacedDigit()
                    Text("0.623529 → \(0.623529.formatted(.number.precision(.fractionLength(colorPickerAccuracy))))")
                        .monospaced()
                }
            } header: {
                Label("Generated Code", systemImage: "chevron.left.forwardslash.chevron.right")
            } footer: {
                Text("Used when generating code for colors picked from the simulator. The default is 2 decimal places.")
                    .caption()
                    .secondary()
            }
        }
        .toggleStyle(.switch)
    }
}

#Preview {
    ColorPickerView()
}
