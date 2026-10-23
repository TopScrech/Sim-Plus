import UniformTypeIdentifiers

/// Finder dialog configuration to select file/s
struct DocumentPickerConfig {

    let canChooseFiles: Bool
    let canChooseDirectories: Bool
    let allowedContentTypes: [UTType]

    init(canChooseFiles: Bool = true, canChooseDirectories: Bool = false, allowedContentTypes: [UTType]) {
        self.canChooseFiles = canChooseFiles
        self.canChooseDirectories = canChooseDirectories
        self.allowedContentTypes = allowedContentTypes
    }
}
