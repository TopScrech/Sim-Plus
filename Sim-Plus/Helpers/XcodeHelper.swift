import Foundation

enum XcodeHelper {
    static func getDeveloperPath() -> String {
        let defaultDeveloperPath = "/Applications/Xcode.app/Contents/Developer"
        let developerPath: String
        if let developerPathData = Process.execute("/usr/bin/xcode-select", arguments: ["-p"]) {
            let result = String(decoding: developerPathData, as: UTF8.self).replacingOccurrences(of: "\\n+$", with: "", options: .regularExpression)
            developerPath = result.isEmpty ? defaultDeveloperPath : result
        } else {
            developerPath = defaultDeveloperPath
        }
        return developerPath
    }
}
