import ScrechKit

struct PathToTerminalTextFieldView: View {
    @EnvironmentObject var preferences: Preferences

    @State private var showFileImporter = false

    private static let defaultTerminalPath = "/System/Applications/Utilities/Terminal.app"

    var body: some View {
        Form {
            Section {
                LabeledContent("Terminal app") {
                    HStack {
                        if isValidPath {
                            Image(nsImage: NSWorkspace.shared.icon(forFile: preferences.terminalAppPath))
                                .resizable()
                                .frame(width: 16, height: 16)
                        }

                        TextField("Terminal app", text: $preferences.terminalAppPath, prompt: Text(Self.defaultTerminalPath))
                            .labelsHidden()

                        Button("Choose…") {
                            showFileImporter = true
                        }
                    }
                }

                if preferences.terminalAppPath != Self.defaultTerminalPath {
                    HStack {
                        Spacer()
                        Button("Reset to Terminal") {
                            preferences.terminalAppPath = Self.defaultTerminalPath
                        }
                    }
                }
            } header: {
                Label("Terminal", systemImage: "terminal")
            } footer: {
                Group {
                    if isValidPath {
                        Text("Used by “Open in Terminal” on the System tab.")
                    } else {
                        Text("No app found at this path. “Open in Terminal” won't work.")
                            .foregroundStyle(.red)
                    }
                }
                .caption()
                .secondary()
            }
        }
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.application]) { result in
            if case .success(let url) = result {
                preferences.terminalAppPath = url.path
            }
        }
    }

    /// Whether the configured path points to an existing app.
    private var isValidPath: Bool {
        preferences.terminalAppPath.hasSuffix(".app") && FileManager.default.fileExists(atPath: preferences.terminalAppPath)
    }
}

#Preview {
    PathToTerminalTextFieldView()
        .environmentObject(Preferences())
}
