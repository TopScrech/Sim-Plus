import Foundation
import AppKit

/// Basic implementation to open Finder and select file/s
struct DocumentPicker {

    static func show(withConfig config: DocumentPickerConfig, selectedFile: ((Data) -> Void)) {
        let dialog = NSOpenPanel()

        dialog.canChooseFiles = config.canChooseFiles
        dialog.canChooseDirectories = config.canChooseDirectories
        dialog.allowedContentTypes = config.allowedContentTypes

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            guard let fileURL = dialog.url, let data = try? Data(contentsOf: fileURL) else { return }

            selectedFile(data)
        }
    }
}
