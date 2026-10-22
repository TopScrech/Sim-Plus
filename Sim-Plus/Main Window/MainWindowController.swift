import ScrechKit
import Cocoa

class MainWindowController: NSWindowController {
    // Without this, AppKit won't call -loadWindow
    override var windowNibName: NSNib.Name? { "None" }

    lazy var preferences: Preferences = Preferences()
    lazy var controller: SimulatorsController = SimulatorsController(preferences: preferences)

    init() {
        super.init(window: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func windowContent() -> some View {
        MainView()
            .environment(controller)
            .environment(DeepLinksController())
            .environment(preferences)
            .environment(UIState.shared)
    }

    override func loadWindow() {
        // Create the window and set the content view.
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 950, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: windowContent())
        window.title = "Control Room"
//        window.isMovableByWindowBackground = true

        // disable the system-generated tab bar menu items, because we can't use them
//        window.tabbingMode = .disallowed

        self.window = window
        adjustWindowLevel()
    }

    private func adjustWindowLevel() {
        withObservationTracking {
            window?.level = preferences.wantsFloatingWindow ? .floating : .normal
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.adjustWindowLevel()
            }
        }
    }

    @IBAction func toggleFloatingWindow(_ sender: Any) {
        preferences.wantsFloatingWindow.toggle()
    }

    @IBAction func showPreferences(_ sender: Any) {
        UIState.shared.currentSheet = .preferences
    }

    @IBAction func newSimulator(_ sender: Any) {
        UIState.shared.currentSheet = .createSimulator
    }
    @IBAction func deleteSelectedSimulators(_ sender: Any) {
        UIState.shared.currentSheet = .confirmDeleteSelected
    }

    @IBAction func deleteUnavailable(_ sender: Any) {
        UIState.shared.currentAlert = .confirmDeleteUnavailable
    }

    @IBAction func showHelp(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/twostraws/ControlRoom")!)
    }
}

extension MainWindowController: NSMenuItemValidation {
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(toggleFloatingWindow(_:)) {
            menuItem.state = preferences.wantsFloatingWindow ? .on : .off
            return true
        }

        if menuItem.action == #selector(newSimulator(_:)) {
            return controller.loadingStatus == .success
        }

        return responds(to: menuItem.action)
    }
}
