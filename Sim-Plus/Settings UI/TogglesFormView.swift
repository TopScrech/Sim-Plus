import SwiftUI

struct TogglesFormView: View {
    @EnvironmentObject private var preferences: Preferences
    var body: some View {
        Form {
            Toggle("Keep window on top", isOn: $preferences.wantsFloatingWindow)
            Toggle("Show Default simulator", isOn: $preferences.showDefaultSimulator)
            Toggle("Show booted devices first", isOn: $preferences.showBootedDevicesFirst)
            Toggle("Show icon in menu bar", isOn: $preferences.wantsMenuBarIcon)
        }
    }
}

#Preview {
    TogglesFormView()
        .environmentObject(Preferences())
}
