import SwiftUI

// macOS 14 compatibility for SwiftUI's macOS 15 windowLevel modifier
struct WindowLevelView: NSViewRepresentable {
    var isFloating: Bool

    func makeNSView(context: Context) -> WindowLevelNSView {
        WindowLevelNSView()
    }

    func updateNSView(_ nsView: WindowLevelNSView, context: Context) {
        nsView.isFloating = isFloating
    }
}
