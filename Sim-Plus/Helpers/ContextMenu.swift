import SwiftUI

extension ContextMenu {
    init?(shouldDisplay: Bool, @ViewBuilder menuItems: () -> MenuItems) {
        guard shouldDisplay == true else { return nil }
        self.init(menuItems: menuItems)
    }
}
