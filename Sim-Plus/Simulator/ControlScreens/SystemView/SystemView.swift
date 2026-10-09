import CoreLocation
import ScrechKit

/// Controls system-wide settings such as time and appearance.
struct SystemView: View {
    let simulator: Simulator

    @EnvironmentObject var preferences: Preferences
    @Environment(DeepLinksController.self) var deepLinks

    @AppStorage("CRApps_LastOpenURL") private var lastOpenURL = ""
    @AppStorage("CRApps_LastCertificateFilePath") private var lastCertificateFilePath = ""

    /// The current state of logging.
    @State private var isLoggingEnabled = false

    /// Whether the user is currently hovering over the area to copy files.
    @State private var dropHovering = false

    /// A destructive action waiting for the user to confirm it.
    @State private var pendingDestructiveAction: DestructiveAction?

    var body: some View {
        Form {
            Section {
                LabeledContent("Device") {
                    Text("\(simulator.name) – \(simulator.runtime?.description ?? "Unknown OS")")
                        .enableSelection()
                }

                LabeledContent("Device ID") {
                    HStack {
                        Text(simulator.udid)
                            .monospaced()
                            .enableSelection()

                        Button(action: copyDeviceID) {
                            Label("Copy Device ID", systemImage: "doc.on.doc")
                        }
                            .labelStyle(.iconOnly)
                            .buttonStyle(.borderless)
                            .help("Copy Device ID")
                    }
                }
            } header: {
                Label("Device", systemImage: "iphone")
            }

            Section {
                pathRow("Root", filePath: .root)

                VStack(alignment: .leading, spacing: 8) {
                    pathRow("Files", filePath: .files)

                    Label(dropHovering ? "Drop to copy" : "Drag files here to copy them to the device", systemImage: "arrow.down.doc")
                        .caption()
                        .foregroundStyle(dropHovering ? Color.accentColor : .secondary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(
                                    dropHovering ? Color.accentColor : Color.secondary.opacity(0.5),
                                    style: StrokeStyle(lineWidth: 1, dash: [4])
                                )
                        }
                }
                .onDrop(of: [.fileURL], isTargeted: $dropHovering) { providers in
                    simulator.copyFilesFromProviders(providers, toFilePath: .files)
                }
            } header: {
                Label("Storage", systemImage: "folder")
            }

            Section {
                LabeledContent("URL") {
                    HStack {
                        TextField("URL", text: $lastOpenURL, prompt: Text("URL or deep link"))
                            .labelsHidden()
                            .onSubmit(openURL)

                        Button("Open", action: openURL)
                            .disabled(lastOpenURL.isEmpty)

                        Menu("Saved") {
                            ForEach(deepLinks.links) { link in
                                Button(link.name) { open(link) }
                            }

                            if deepLinks.links.isEmpty == false {
                                Divider()
                            }

                            Button("Customize…") {
                                UIState.shared.currentSheet = .deepLinkEditor
                            }
                        }
                        .fixedSize()
                    }
                }

                LabeledContent("Root certificate") {
                    HStack {
                        TextField("Root certificate", text: $lastCertificateFilePath, prompt: Text("Full path to a trusted root certificate"))
                            .labelsHidden()
                            .onSubmit(addRootCertificate)

                        Button("Add", action: addRootCertificate)
                            .disabled(lastCertificateFilePath.isEmpty)
                    }
                }
            } header: {
                Label("Links & Certificates", systemImage: "link")
            }

            Section {
                LabeledContent("Pasteboard") {
                    HStack {
                        Button("Simulator → Mac", action: copyPasteboardToMac)
                        Button("Mac → Simulator", action: copyPasteboardToSim)
                    }
                }

                LabeledContent("iCloud") {
                    Button("Trigger Sync", action: triggerSync)
                }

                LabeledContent("Logging") {
                    HStack {
                        if isLoggingEnabled {
                            Button("Get Logs", action: getLogs)
                        }

                        Toggle("Logging", isOn: Binding(get: { isLoggingEnabled }, set: { _ in updateLogging() }))
                            .labelsHidden()
                            .toggleStyle(.switch)
                    }
                }
            } header: {
                Label("Data", systemImage: "arrow.left.arrow.right")
            }

            Section {
                LabeledContent("Keychain") {
                    Button("Reset Keychain…", role: .destructive) {
                        pendingDestructiveAction = .resetKeychain
                    }
                }

                LabeledContent("Content & settings") {
                    Button("Erase Device…", role: .destructive) {
                        pendingDestructiveAction = .erase
                    }
                }
            } header: {
                Label("Reset", systemImage: "exclamationmark.triangle")
            }
        }
        .formStyle(.grouped)
        .confirmationDialog(
            pendingDestructiveAction?.title ?? "",
            isPresented: Binding(get: { pendingDestructiveAction != nil }, set: { if $0 == false { pendingDestructiveAction = nil } }),
            presenting: pendingDestructiveAction
        ) { action in
            Button(action.confirmTitle, role: .destructive) {
                switch action {
                case .resetKeychain: resetKeychain()
                case .erase: eraseDevice()
                }
            }
        } message: { action in
            Text(action.message)
        }
        .tabItem {
            Text("System")
        }
        .onAppear {
            isLoggingEnabled = UserDefaults.standard.bool(forKey: "\(simulator.udid).logging")
        }
    }

    /// A labeled path with buttons to copy it or reveal it in Finder or Terminal.
    private func pathRow(_ title: LocalizedStringKey, filePath: Simulator.FilePathKind) -> some View {
        LabeledContent(title) {
            HStack {
                Text(simulator.urlForFilePath(filePath).relativePath)
                    .lineLimit(1)
                    .truncationMode(.head)
                    .enableSelection()
                    .help(simulator.urlForFilePath(filePath).relativePath)

                Button { copyPath(filePath) } label: {
                    Label("Copy Path", systemImage: "doc.on.doc")
                }
                    .help("Copy Path")

                Button { openInFinder(filePath) } label: {
                    Label("Open in Finder", systemImage: "folder")
                }
                    .help("Open in Finder")

                Button { openInTerminal(filePath) } label: {
                    Label("Open in Terminal", systemImage: "terminal")
                }
                    .help("Open in Terminal")
                    .disabled(preferences.terminalAppPath.isEmpty)
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
        }
    }

    /// Starts an immediate iCloud sync.
    func triggerSync() {
        SimCtl.triggeriCloudSync(simulator.udid)
    }
    /// Update logging.
    func updateLogging() {
        if isLoggingEnabled {
            SimCtl.setLogging(simulator, enableLogging: false)
            isLoggingEnabled = false
        } else {
            SimCtl.setLogging(simulator, enableLogging: true)
            isLoggingEnabled = true
        }
    }
    /// Get logs.
    func getLogs() {
        SimCtl.getLogs(simulator.udid)
    }

    /// Copies the simulator's pasteboard to the Mac.
    func copyPasteboardToMac() {
        SimCtl.copyPasteboardToMac(simulator.udid)
    }

    /// Copies the Mac's pasteboard to the simulator.
    func copyPasteboardToSim() {
        SimCtl.copyPasteboardToSimulator(simulator.udid)
    }

    /// Opens a URL in the appropriate device app.
    func openURL() {
        SimCtl.openURL(simulator.udid, URL: lastOpenURL)
    }

    func addRootCertificate() {
        SimCtl.addRootCertificate(simulator.udid, filePath: lastCertificateFilePath)
    }

    /// Erases the current device.
    func eraseDevice() {
        SimCtl.erase(simulator.udid)
    }

    /// Resets the keychain on the current device
    func resetKeychain() {
        SimCtl.execute(.keychain(deviceId: simulator.udid, action: .reset))
    }

    func copyDeviceID() {
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(simulator.udid, forType: .string)
    }

    func copyPath(_ filePath: Simulator.FilePathKind) {
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(simulator.urlForFilePath(filePath).relativePath, forType: .string)
    }

    func openInFinder(_ filePath: Simulator.FilePathKind) {
        simulator.open(filePath)
    }

    func openInTerminal(_ filePath: Simulator.FilePathKind) {
        guard preferences.terminalAppPath.isNotEmpty else { return }

        let terminalUrl = URL(fileURLWithPath: preferences.terminalAppPath) as CFURL
        let unmanagedTerminalUrl = Unmanaged<CFURL>.passUnretained(terminalUrl)
        let folderUrl = simulator.urlForFilePath(filePath)
        let unmanagedFolderUrl = Unmanaged<CFArray>.passRetained([folderUrl] as CFArray)

        let launchSpec = LSLaunchURLSpec(appURL: unmanagedTerminalUrl, itemURLs: unmanagedFolderUrl, passThruParams: nil, launchFlags: [], asyncRefCon: nil)

        _ = withUnsafePointer(to: launchSpec) { (pointer: UnsafePointer<LSLaunchURLSpec>) in
            LSOpenFromURLSpec(pointer, nil)
        }
    }

    func open(_ link: DeepLink) {
        SimCtl.openURL(simulator.udid, URL: link.url.absoluteString)
    }
}

struct SystemView_Previews: PreviewProvider {
    static var previews: some View {
        let preferences = Preferences()

        SystemView(simulator: .example)
            .environmentObject(preferences)
    }
}

extension SimCtl.UI.Appearance {
    var displayName: String {
        rawValue.capitalized
    }
}

/// A destructive System tab action that needs confirmation.
private enum DestructiveAction {
    case resetKeychain, erase

    var title: String {
        switch self {
        case .resetKeychain: "Reset the keychain?"
        case .erase: "Erase this device?"
        }
    }

    var message: String {
        switch self {
        case .resetKeychain: "All keychain items on the simulator will be removed."
        case .erase: "All content and settings on the simulator will be erased. This can't be undone."
        }
    }

    var confirmTitle: String {
        switch self {
        case .resetKeychain: "Reset Keychain"
        case .erase: "Erase"
        }
    }
}
