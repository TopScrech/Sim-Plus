import ScrechKit

struct ThermalOverrideView: View {
    @State private var controller: ThermalOverrideController
    let simulator: Simulator

    init(simulator: Simulator) {
        self.simulator = simulator
        _controller = State(initialValue: ThermalOverrideController(deviceID: simulator.udid))
    }

    var body: some View {
        Section {
            Toggle("Override Thermal State", isOn: $controller.isEnabled)
                .onChange(of: controller.isEnabled) {
                    Task { await controller.update() }
                }

            if controller.isEnabled {
                Picker("Thermal State", selection: $controller.state) {
                    ForEach(ThermalState.allCases, id: \.self) {
                        Text($0.title)
                            .tag($0)
                    }
                }
                .onChange(of: controller.state) {
                    Task { await controller.update() }
                }
            }

            if let errorMessage = controller.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }
        } header: {
            Label("Thermal State", systemImage: "thermometer.medium")
        } footer: {
            Text("Simulates thermal pressure for apps in this simulator until it restarts or the value changes elsewhere\nTurning off the override restores the previous value")
                .caption()
                .secondary()
        }
        .disabled(controller.isUpdating)
        .task(id: simulator.state) {
            if simulator.state == .booted {
                await controller.refresh()
            }
        }
    }
}
