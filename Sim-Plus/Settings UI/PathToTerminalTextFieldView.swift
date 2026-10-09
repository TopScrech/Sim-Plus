import SwiftUI

struct PathToTerminalTextFieldView: View {
    @EnvironmentObject var preferences: Preferences

    var body: some View {
        Form {
            TextField(
                "Path to Terminal",
                text: $preferences.terminalAppPath
            )
            .textFieldStyle(.roundedBorder)
        }
    }
}

#Preview {
    PathToTerminalTextFieldView()
        .environmentObject(Preferences())
}
