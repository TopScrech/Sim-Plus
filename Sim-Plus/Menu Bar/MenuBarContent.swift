import KeyboardShortcuts
import ScrechKit

/// The contents of the menu bar extra: quick access to simulators and the last used app actions.
struct MenuBarContent: View {
    @Environment(SimulatorsController.self) private var controller
    @Environment(DeepLinksController.self) private var deepLinks
    @Environment(\.openWindow) private var openWindow

    @AppStorage("CRLastSimulatorUDID") private var lastSimulatorUDID = ""

    var body: some View {
        Button("Open Sim+", action: openMainWindow)

        Divider()

        simulatorsSection

        Divider()

        Section("Target: \(targetName)") {
            Button("Resend Last Push Notification", action: QuickActions.resendLastPushNotification)
                .globalKeyboardShortcut(.resendLastPushNotification)
                .disabled(QuickActions.hasLastApp == false)

            Button("Restart Last Selected App", action: QuickActions.restartLastSelectedApp)
                .globalKeyboardShortcut(.restartLastSelectedApp)
                .disabled(QuickActions.hasLastApp == false)

            Button("Reopen Last URL", action: QuickActions.reopenLastURL)
                .globalKeyboardShortcut(.reopenLastURL)
                .disabled(QuickActions.hasLastURL == false)

            if deepLinks.links.isNotEmpty {
                Menu("Saved Deep Links") {
                    ForEach(deepLinks.links) { link in
                        Button(link.name) {
                            QuickActions.open(link)
                        }
                    }
                }
            }
        }

        Divider()

        SettingsLink {
            Text("Settings...")
        }
        .keyboardShortcut(",")

        Button("Quit Sim+") {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q")
    }

    @ViewBuilder
    private var simulatorsSection: some View {
        switch controller.loadingStatus {
        case .success:
            if bootedSimulators.isEmpty {
                Text("No Booted Simulators")
            } else {
                Section("Booted") {
                    ForEach(bootedSimulators) { simulator in
                        Menu(simulator.menuTitle) {
                            Button("Show in Sim+") {
                                select(simulator)
                            }

                            Button("Use for Quick Actions") {
                                lastSimulatorUDID = simulator.udid
                            }

                            Divider()

                            Button("Reboot") {
                                SimCtl.reboot(simulator)
                            }

                            Button("Shutdown") {
                                SimCtl.shutdown(simulator.udid)
                            }
                        }
                    }
                }
            }

            if shutdownSimulatorsByRuntime.isNotEmpty {
                Menu("Boot Simulator") {
                    ForEach(shutdownSimulatorsByRuntime, id: \.runtime) { group in
                        Section(group.runtime) {
                            ForEach(group.simulators) { simulator in
                                Button(simulator.name) {
                                    SimCtl.boot(simulator)
                                    lastSimulatorUDID = simulator.udid
                                }
                            }
                        }
                    }
                }
            }

        case .loading:
            Text("Loading Simulators...")

        case .failed, .invalidCommandLineTool:
            Text("Couldn't Load Simulators")
        }
    }

    private var bootedSimulators: [Simulator] {
        controller.allSimulators
            .filter { $0.state != .shutdown }
            .sorted()
    }

    private var shutdownSimulatorsByRuntime: [(runtime: String, simulators: [Simulator])] {
        let shutdown = controller.allSimulators.filter { $0.state == .shutdown }
        let grouped = Dictionary(grouping: shutdown) { $0.runtime?.name ?? Runtime.unknown.name }

        return grouped
            .map { (runtime: $0.key, simulators: $0.value.sorted()) }
            .sorted { $0.runtime.localizedStandardCompare($1.runtime) == .orderedAscending }
    }

    private var targetName: String {
        let udid = QuickActions.lastSimulatorUDID
        return controller.allSimulators.first { $0.udid == udid }?.name ?? Simulator.default.name
    }

    private func openMainWindow() {
        openWindow(id: "main")
        NSApp.activate()
    }

    private func select(_ simulator: Simulator) {
        controller.selectedSimulatorIDs = [simulator.udid]
        openMainWindow()
    }
}

private extension Simulator {
    var menuTitle: String {
        if let runtime {
            "\(name) (\(runtime.name))"
        } else {
            name
        }
    }
}
