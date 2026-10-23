import KeyboardShortcuts
import ScrechKit

@main
struct ControlRoomApp: App {
    @AppStorage("CRWantsMenuBarIcon") private var wantsMenuBarIcon = true

    @State var preferences: Preferences
    @State var controller: SimulatorsController
    @State var deepLinks = DeepLinksController()

    var body: some Scene {
        Window("Control Room", id: "main") {
            MainView()
                .environment(controller)
                .environment(preferences)
                .environment(UIState.shared)
                .environment(deepLinks)
        }
        .commands {
            SimulatorCommands()
            SidebarCommands()

            CommandGroup(replacing: .appInfo) {
                Button("About Control Room") {
                    let authors = Bundle.main.authors

                    if authors.isNotEmpty {
                        let content = NSViewController()
                        content.title = "Control Room"
                        let view = NSHostingView(rootView: AboutView(authors: authors))
                        view.frame.size = view.fittingSize
                        content.view = view
                        let panel = NSPanel(contentViewController: content)
                        panel.styleMask = [.closable, .titled]
                        panel.orderFront(nil)
                        panel.makeKey()
                    } else {
                        NSApp.orderFrontStandardAboutPanel(nil)
                    }
                }
            }
        }

        Settings {
            SettingsView()
                .environment(preferences)
        }

        MenuBarExtra("Sim+", systemImage: "iphone", isInserted: $wantsMenuBarIcon) {
            MenuBarContent()
                .environment(controller)
                .environment(deepLinks)
        }
    }

    init() {
        let preferences = Preferences()
        let controller = SimulatorsController(preferences: preferences)
        _preferences = State(initialValue: preferences)
        _controller = State(initialValue: controller)

        controller.startWatching()
        registerGlobalShortcuts()
    }

    private func registerGlobalShortcuts() {
        KeyboardShortcuts.onKeyUp(for: .resendLastPushNotification, action: QuickActions.resendLastPushNotification)
        KeyboardShortcuts.onKeyUp(for: .restartLastSelectedApp, action: QuickActions.restartLastSelectedApp)
        KeyboardShortcuts.onKeyUp(for: .reopenLastURL, action: QuickActions.reopenLastURL)
    }
}
