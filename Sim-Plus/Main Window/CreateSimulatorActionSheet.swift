import ScrechKit

struct CreateSimulatorActionSheet: View {
    @Environment(SimulatorsController.self) private var controller

    @State private var deviceType: DeviceType?
    @State private var runtime: Runtime?
    @State private var name: String = ""

    init(deviceType: DeviceType?, runtime: Runtime?) {
        _deviceType = State(initialValue: deviceType)
        _runtime = State(initialValue: runtime)
    }

    private var canCreate: Bool {
        name.isNotEmpty && deviceType != nil && runtime != nil && warning == nil
    }

    private var warning: String? {
        guard let deviceType, let runtime else { return nil }
        let supportedFamilies = runtime.supportedFamilies
        if supportedFamilies.contains(deviceType.family) { return nil }

        let familyList = ListFormatter().string(from: supportedFamilies.map(\.displayName))!
        return "\(runtime.name) can only be used with \(familyList) devices."
    }

    var body: some View {
        SimulatorActionSheet(
            icon: (deviceType?.modelTypeIdentifier ?? .defaultiPhone).icon,
            message: "Create Simulator",
            informativeText: "Choose the device type and operating system for the new simulator",
            confirmationTitle: "Create",
            confirm: confirm,
            canConfirm: canCreate,
            content: {
                Form {
                    TextField("Name", text: $name)

                    Picker("Device", selection: $deviceType) {
                        ForEach(controller.deviceTypes) {
                            Text($0.name).tag(Optional($0))
                        }
                    }

                    Picker("System", selection: $runtime) {
                        ForEach(controller.runtimes) {
                            Text($0.name).tag(Optional($0))
                        }
                    }

                    if let warning {
                        HStack(alignment: .top) {
                            Image(nsImage: NSImage(named: NSImage.cautionName)!)
                                .resizable()
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(width: 18)
                            Text(warning)
                        }
                    }
                }
            }
        )
    }

    private func confirm() {
        guard let deviceType, let runtime else { return }
        SimCtl.create(name: name, deviceType: deviceType, runtime: runtime)
    }
}
