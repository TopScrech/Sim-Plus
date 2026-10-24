import SwiftUI

enum ThermalState: Int, CaseIterable {
    // Simulator notification values corresponding to ProcessInfo thermal states
    case nominal = 0, fair = 10, serious = 20, critical = 30

    var title: LocalizedStringKey {
        switch self {
        case .nominal: "Nominal"
        case .fair: "Fair"
        case .serious: "Serious"
        case .critical: "Critical"
        }
    }
}
