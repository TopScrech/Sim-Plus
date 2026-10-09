import Combine

class UIState: ObservableObject {
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
    @Published var currentSheet: Sheet?
    @Published var currentAlert: Alert?

    private init() { }
}
