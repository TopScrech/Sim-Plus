import KeyboardShortcuts
import ScrechKit

struct SettingsView: View {
    var body: some View {
        TabView {
            TogglesFormView()
                .padding()
                .maxFrame(.infinity)
                .tabItem {
                    Label("Window", systemImage: "macwindow")
                }

            NotificationsFormView()
                .padding()
                .maxFrame(.infinity)
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }

            PickersFormView()
                .padding()
                .maxFrame(.infinity)
                .tabItem {
                    Label("Screenshots", systemImage: "camera.on.rectangle")
                }

            ColorPickerView()
                .padding()
                .maxFrame(.infinity)
                .tabItem {
                    Label("Colors", systemImage: "paintpalette")
                }

            PathToTerminalTextFieldView()
                .padding()
                .maxFrame(.infinity)
                .tabItem {
                    Label("Locations", systemImage: "externaldrive")
                }
        }
        .frame(minWidth: 550)
    }
}

#Preview {
    SettingsView()
        .environmentObject(Preferences())
}
