import Foundation

@Observable
final class ThermalOverrideController {
    var isEnabled = false
    var state: ThermalState = .serious
    private(set) var isUpdating = false
    private(set) var errorMessage: String?

    private let deviceID: String
    private var previousValue: Int?
    private var appliedValue: Int?
    private var storageKey: String { "\(deviceID).thermalOverride" }

    init(deviceID: String) {
        self.deviceID = deviceID
        let saved = UserDefaults.standard.dictionary(forKey: storageKey)
        previousValue = saved?["previousValue"] as? Int
        appliedValue = saved?["state"] as? Int
        isEnabled = previousValue != nil && appliedValue != nil
        state = appliedValue.flatMap(ThermalState.init(rawValue:)) ?? (appliedValue == nil ? .serious : .critical)
    }

    func update() async {
        guard !isUpdating, isEnabled != (appliedValue != nil) || (isEnabled && state.rawValue != appliedValue) else { return }
        isUpdating = true
        errorMessage = nil
        defer { isUpdating = false }

        do {
            if isEnabled {
                if previousValue == nil {
                    previousValue = try await readValue()
                }
                try await writeValue(state.rawValue)
                appliedValue = state.rawValue
                UserDefaults.standard.set(["previousValue": previousValue ?? 0, "state": state.rawValue], forKey: storageKey)
            } else if let previousValue {
                try await writeValue(previousValue)
                self.previousValue = nil
                appliedValue = nil
                UserDefaults.standard.removeObject(forKey: storageKey)
            }
        } catch {
            errorMessage = error.localizedDescription
            isEnabled = appliedValue != nil
            state = appliedValue.flatMap(ThermalState.init(rawValue:)) ?? state
            if appliedValue == nil {
                previousValue = nil
            }
        }
    }

    func refresh() async {
        guard !isUpdating else { return }
        isUpdating = true
        defer { isUpdating = false }

        do {
            let currentValue = try await readValue()
            if currentValue != appliedValue {
                previousValue = nil
                appliedValue = nil
                isEnabled = false
                UserDefaults.standard.removeObject(forKey: storageKey)
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func readValue() async throws -> Int {
        let output = try await runNotify(["-q", "-g", "com.apple.system.thermalpressurelevel"])
        return try Self.parseValue(output)
    }

    static func parseValue(_ output: String) throws -> Int {
        let fields = output.split(whereSeparator: \.isWhitespace)
        let isValueOnly = fields.count == 1
        let isNamedValue = fields.count == 2 && fields.first == "com.apple.system.thermalpressurelevel"
        guard isValueOnly || isNamedValue, let last = fields.last, let value = Int(last), value >= 0 else {
            throw ThermalOverrideError.unexpectedOutput(output.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return value
    }

    private func writeValue(_ value: Int) async throws {
        let name = "com.apple.system.thermalpressurelevel"
        _ = try await runNotify(["-s", name, String(value), "-p", name])
        guard try await readValue() == value else {
            throw ThermalOverrideError.overrideNotApplied
        }
    }

    private func runNotify(_ arguments: [String]) async throws -> String {
        let deviceID = deviceID
        return try await Task.detached(priority: .userInitiated) {
            let process = Process()
            process.executableURL = URL(filePath: "/usr/bin/xcrun")
            process.arguments = ["simctl", "spawn", deviceID, "notifyutil"] + arguments
            let pipe = Pipe()
            process.standardOutput = pipe
            let errorPipe = Pipe()
            process.standardError = errorPipe
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            let output = String(decoding: data, as: UTF8.self)
            guard process.terminationStatus == 0 else {
                throw NSError(domain: "ThermalOverride", code: Int(process.terminationStatus), userInfo: [
                    NSLocalizedDescriptionKey: String(decoding: errorData, as: UTF8.self)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                ])
            }
            return output
        }.value
    }
}
