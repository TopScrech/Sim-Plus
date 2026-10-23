import ScrechKit

struct SimulatorCommands: Commands {
    @FocusedValue(SimulatorsController.self) private var controller
    @FocusedValue(Preferences.self) private var preferences
    @Environment(\.openURL) private var openURL

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Simulator…", systemImage: "plus") {
                UIState.shared.currentSheet = .createSimulator
            }
            .keyboardShortcut("n")
            .disabled(controller?.loadingStatus != .success)

            Button("Delete Unavailable Simulators…", systemImage: "trash") {
                UIState.shared.currentAlert = .confirmDeleteUnavailable
            }
            .keyboardShortcut("d", modifiers: [.command, .shift])
            .disabled(controller?.loadingStatus != .success)
        }

        CommandGroup(before: .pasteboard) {
            Button("Delete Selected Simulators…", systemImage: "trash") {
                UIState.shared.currentSheet = .confirmDeleteSelected
            }
            .keyboardShortcut(.delete)
            .disabled(controller?.loadingStatus != .success || controller?.selectedSimulators.isEmpty != false)

            Divider()
        }

        CommandGroup(after: .windowArrangement) {
            if let preferences {
                @Bindable var preferences = preferences

                Toggle("Stay In Front", isOn: $preferences.wantsFloatingWindow)
                    .keyboardShortcut("f", modifiers: [.command, .shift])
            }
        }

        CommandGroup(replacing: .help) {
            Button("Project GitHub", systemImage: "questionmark.circle") {
                if let url = URL(string: "https://github.com/twostraws/ControlRoom") {
                    openURL(url)
                }
            }
            .keyboardShortcut("/", modifiers: [.command, .shift])
        }
    }
}
