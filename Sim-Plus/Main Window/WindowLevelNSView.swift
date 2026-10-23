import AppKit

final class WindowLevelNSView: NSView {
    var isFloating = false {
        didSet {
            updateWindowLevel()
        }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateWindowLevel()
    }

    private func updateWindowLevel() {
        window?.level = isFloating ? .floating : .normal
    }
}
