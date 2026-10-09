import Foundation
import UniformTypeIdentifiers

/// Finder dialog configuration to select file/s
struct DocumentPickerConfig {

    let showHiddenFiles: Bool
    let canChooseFiles: Bool
    let canChooseDirectories: Bool
    let allowedContentTypes: [UTType]

    init(showHiddenFiles: Bool = false, canChooseFiles: Bool = true, canChooseDirectories: Bool = false, allowedContentTypes: [UTType]) {
        self.showHiddenFiles = showHiddenFiles
        self.canChooseFiles = canChooseFiles
        self.canChooseDirectories = canChooseDirectories
        self.allowedContentTypes = allowedContentTypes
    }
}
