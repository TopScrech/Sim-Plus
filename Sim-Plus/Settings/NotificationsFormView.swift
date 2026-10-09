import ScrechKit
import KeyboardShortcuts

struct NotificationsFormView: View {
    var body: some View {
        Form {
            makeKeyboardShortcut(title: "Resend last push notification", for: .resendLastPushNotification)
            makeKeyboardShortcut(title: "Restart last selected app", for: .restartLastSelectedApp)
            makeKeyboardShortcut(title: "Reopen last URL", for: .reopenLastURL)
        }
    }

    private func makeKeyboardShortcut(title: String, for name: KeyboardShortcuts.Name) -> some View {
        HStack {
            Text(title)
            KeyboardShortcuts.Recorder(for: name)
        }
    }
}

#Preview {
    NotificationsFormView()
}
