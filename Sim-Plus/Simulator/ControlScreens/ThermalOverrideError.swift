import Foundation

enum ThermalOverrideError: LocalizedError {
    case unexpectedOutput(String)
    case overrideNotApplied

    var errorDescription: String? {
        switch self {
        case .unexpectedOutput(let output):
            String(localized: "Could not read the simulator’s thermal state: \(output)")
        case .overrideNotApplied:
            String(localized: "The simulator did not apply the thermal override")
        }
    }
}
