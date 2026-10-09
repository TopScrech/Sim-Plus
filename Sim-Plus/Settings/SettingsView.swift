import KeyboardShortcuts
import ScrechKit

struct SettingsView: View {
    var body: some View {
        TabView {
            TogglesFormView()
                .tabItem {
                    Label("Window", systemImage: "macwindow")
                }

            NotificationsFormView()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }

            PickersFormView()
                .tabItem {
                    Label("Screenshots", systemImage: "camera.on.rectangle")
                }

            ColorPickerView()
                .tabItem {
                    Label("Colors", systemImage: "paintpalette")
                }

            PathToTerminalTextFieldView()
                .tabItem {
                    Label("Locations", systemImage: "externaldrive")
                }
        }
        .formStyle(.grouped)
        .frame(width: 550, height: 440)
    }
}

#Preview {
    SettingsView()
        .environmentObject(Preferences())
}
