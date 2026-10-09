import Foundation
import ScrechKit

/// A centralized class that loads simulator data and handles filtering.
@MainActor
@Observable
class SimulatorsController {
    /// Tracks the state of fetching simulator data from simctl.
    enum LoadingStatus {
        /// Loading is in progress
        case loading

        /// Loading succeeded
        case success

        /// Loading failed
        case failed

        /// Invalid command line tool
        case invalidCommandLineTool
    }

    /// The current loading state; defaults to .loading
    var loadingStatus: LoadingStatus = .loading

    /// An array of all simulators that match the user's current filter.
    var simulators = [Simulator]()

    /// An array of all the applications installed on the selected simulator.
    var applications = [Application]()

    /// An array of all the snapshots of the selected simulator.
    var snapshots = [Snapshot]()

    /// An array of all simulators that were loaded from simctl.
    private var allSimulators = [Simulator]()

    private(set) var deviceTypes = [DeviceType]()
    private(set) var runtimes = [Runtime]()
    @ObservationIgnored private var applicationsTask: Task<Void, Never>?
    @ObservationIgnored private var snapshotsTask: Task<Void, Never>?

    @ObservationIgnored @AppStorage("CRSidebar_FilterText") private var filterText = ""

    /// The simulators the user has selected to work with. If this has one item then
    /// they are working with a simulator; if more than one they are probably about
    /// to delete several at a time.
    var selectedSimulatorIDs = Set<String>() {
        didSet {
            guard selectedSimulatorIDs != oldValue else { return }
            loadApplications()
            loadSnapshots()
        }
    }

    var selectedSimulators: [Simulator] {
        var selected = [Simulator]()
        if selectedSimulatorIDs.contains(Simulator.default.udid) {
            selected.append(Simulator.default)
        }
        selected.append(contentsOf: allSimulators.filter { selectedSimulatorIDs.contains($0.udid) })
        return selected
    }

    let preferences: Preferences

    init(preferences: Preferences) {
        self.preferences = preferences
    }

    /// Refreshes simulator data until the hosting view disappears
    func watchSimulators() async {
        defer {
            applicationsTask?.cancel()
            snapshotsTask?.cancel()
        }
        loadApplications()
        loadSnapshots()
        loadingStatus = .loading
        let tool = await XcodeCommandLineToolsController.selectedCommandLineTool()
        guard !Task.isCancelled else { return }
        guard tool != .empty else {
            loadingStatus = .invalidCommandLineTool
            return
        }

        do {
            async let types = SimCtl.listDeviceTypes()
            async let availableRuntimes = SimCtl.listRuntimes()
            let (deviceTypes, runtimes) = try await (types, availableRuntimes)
            var previousDevices: SimCtl.DeviceList?

            while !Task.isCancelled {
                let devices = try await SimCtl.listDevices()
                try Task.checkCancellation()
                if devices != previousDevices {
                    handleLoadedInformation(devices, deviceTypes, runtimes)
                    previousDevices = devices
                }
                try await Task.sleep(for: .seconds(5))
            }
        } catch is CancellationError {
            // Stop polling when the hosting view disappears
        } catch {
            loadingStatus = .failed
        }
    }

    private func handleLoadedInformation(_ deviceList: SimCtl.DeviceList,
                                         _ deviceTypes: SimCtl.DeviceTypeList,
                                         _ runtimes: SimCtl.RuntimeList) {
        var final = [Simulator]()

        let lookupDeviceType = Dictionary(grouping: deviceTypes.devicetypes, by: \.identifier).compactMapValues(\.first)
        let lookupRuntime = Dictionary(grouping: runtimes.runtimes, by: \.identifier).compactMapValues(\.first)

        for (runtimeIdentifier, devices) in deviceList.devices {
            let runtime: SimCtl.Runtime?

            if let known = lookupRuntime[runtimeIdentifier] {
                runtime = known
            } else if let parsed = SimCtl.Runtime(runtimeIdentifier: runtimeIdentifier) {
                runtime = parsed
            } else {
                runtime = nil
            }

            for device in devices {
                let type = lookupDeviceType[device.deviceTypeIdentifier ?? ""]
                let state = Simulator.State(deviceState: device.state)

                let sim = Simulator(name: device.name,
                                    udid: device.udid,
                                    state: state,
                                    runtime: runtime,
                                    deviceType: type,
                                    dataPath: device.dataPath ?? "")
                final.append(sim)
            }

            if let device = devices.first {
                SnapshotCtl.configureDevicesPath(dataPath: device.dataPath)
            }
        }

        self.deviceTypes = deviceTypes.devicetypes
        self.runtimes = runtimes.runtimes
        loadingStatus = .success
        allSimulators = final
        let previousSelection = selectedSimulatorIDs
        filterSimulators()
        if selectedSimulatorIDs == previousSelection {
            loadApplications()
            loadSnapshots()
        }
    }

    /// Filters the list of simulators using `filterText`, and assigns the result to `simulators`.
    func filterSimulators() {
        guard loadingStatus == .success else { return }

        let trimmed = filterText.trimmingCharacters(in: .whitespacesAndNewlines)
        var filtered = allSimulators

        if preferences.showBootedDevicesFirst {
            let booted = filtered.filter { $0.state != .shutdown }
            let shutdown = filtered.filter { $0.state == .shutdown }
            filtered = booted.sorted() + shutdown.sorted()
        } else {
            filtered = filtered.sorted()
        }

        if preferences.showDefaultSimulator {
            filtered = [.default] + filtered
        }

        if trimmed.isNotEmpty {
            filtered = filtered.filter { $0.name.localizedStandardContains(trimmed) }
        }

        if preferences.shouldShowOnlyActiveDevices == true {
            filtered = filtered.filter { $0.state != .shutdown }
        }

        simulators = filtered

        let oldSelection = selectedSimulatorIDs
        let selectableIDs = Set(filtered.map(\.udid))
        let newSelection = oldSelection.intersection(selectableIDs)

        if newSelection != oldSelection {
            selectedSimulatorIDs = newSelection
        }
    }

    private func loadApplications() {
        applicationsTask?.cancel()
        guard let selectedDeviceUDID = selectedSimulatorIDs.first else {
            applications = []
            return
        }

        applicationsTask = Task { [weak self] in
            let list = (try? await SimCtl.listApplications(selectedDeviceUDID)) ?? SimCtl.ApplicationsList()
            guard !Task.isCancelled else { return }
            self?.applications = list.values.compactMap(Application.init)
        }
    }

    private func loadSnapshots() {
        snapshotsTask?.cancel()
        guard let selectedDeviceUDID = selectedSimulatorIDs.first else {
            snapshots = []
            return
        }

        snapshotsTask = Task { [weak self] in
            do {
                while !Task.isCancelled {
                    self?.snapshots = SnapshotCtl.getSnapshots(deviceId: selectedDeviceUDID)
                    try await Task.sleep(for: .seconds(5))
                }
            } catch {
                // Stop polling when the selection changes
            }
        }
    }

    deinit {
        applicationsTask?.cancel()
        snapshotsTask?.cancel()
    }
}
