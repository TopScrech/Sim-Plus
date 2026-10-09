import ScrechKit
import KeyboardShortcuts

struct NotificationsFormView: View {
    var body: some View {
        Form {
            Section {
                makeKeyboardShortcut(title: "Resend last push notification", for: .resendLastPushNotification)
                makeKeyboardShortcut(title: "Restart last selected app", for: .restartLastSelectedApp)
                makeKeyboardShortcut(title: "Reopen last URL", for: .reopenLastURL)
            } header: {
                Label("Global Shortcuts", systemImage: "keyboard")
            } footer: {
                Text("These shortcuts work even when Sim+ isn't the active app.")
                    .caption()
                    .secondary()
            }
        }
    }

    private func makeKeyboardShortcut(title: String, for name: KeyboardShortcuts.Name) -> some View {
        LabeledContent(title) {
            KeyboardShortcuts.Recorder(for: name)
        }
    }
}

#Preview {
    NotificationsFormView()
}
