import ScrechKit

struct TogglesFormView: View {
    @EnvironmentObject private var preferences: Preferences

    var body: some View {
        Form {
            Section {
                Toggle("Keep window on top", isOn: $preferences.wantsFloatingWindow)
                Toggle("Show icon in menu bar", isOn: $preferences.wantsMenuBarIcon)
            } header: {
                Label("Window", systemImage: "macwindow")
            }

            Section {
                Toggle("Show Default simulator", isOn: $preferences.showDefaultSimulator)
                Toggle("Show booted devices first", isOn: $preferences.showBootedDevicesFirst)
            } header: {
                Label("Simulator List", systemImage: "sidebar.left")
            }
        }
        .toggleStyle(.switch)
    }
}

#Preview {
    TogglesFormView()
        .environmentObject(Preferences())
}
