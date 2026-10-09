import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            TogglesFormView()
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tabItem {
                    Label("Window", systemImage: "macwindow")
                }

            NotificationsFormView()
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }

            PickersFormView()
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tabItem {
                    Label("Screenshots", systemImage: "camera.on.rectangle")
                }

            ColorPickerView()
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tabItem {
                    Label("Colors", systemImage: "paintpalette")
                }

            PathToTerminalTextFieldView()
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
