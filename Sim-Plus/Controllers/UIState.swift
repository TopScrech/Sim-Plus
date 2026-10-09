import Foundation

@Observable
class UIState {
    enum Sheet: Int, Identifiable {
        case preferences
        case createSimulator
        case deepLinkEditor
        case notificationEditor
        case confirmDeleteSelected

        var id: Int { rawValue }
    }

    enum Alert: Int, Identifiable {
        case confirmDeleteUnavailable

        var id: Int { rawValue }
    }

    static let shared = UIState()
    var currentSheet: Sheet?
    var currentAlert: Alert?

    private init() { }
}
