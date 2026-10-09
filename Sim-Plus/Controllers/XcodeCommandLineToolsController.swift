import Foundation

struct XcodeCommandLineToolsController {
    static func selectedCommandLineTool() async -> DeveloperTool {
        do {
            async let tools = SystemProfiler.listDeveloperTools()
            async let path = XcodeSelect.printPath()
            let (developerTools, selectedPath) = try await (tools, path)
            return developerTools.first {
                selectedPath.contains($0.path) && $0.version >= "11.4"
            } ?? .empty
        } catch {
            return .empty
        }
    }

}

private enum XcodeSelect: CommandLineCommandExecuter {
    typealias Error = CommandLineError

    static var launchPath = "/usr/bin/xcode-select"

    static func printPath() async throws -> String {
        let data = try await XcodeSelect.executeData(.printPath())
        return String(data: data, encoding: .utf8) ?? ""
    }
}

private extension XcodeSelect {
    struct Command: CommandLineCommand {
        let arguments: [String]
        var environmentOverrides: [String: String]? { nil }

        private init(_ subcommand: String, arguments: [String]) {
            self.arguments = [subcommand] + arguments
        }

        /// Print the path of the active developer directory.
        static func printPath() -> Command {
            Command("-p", arguments: [])
        }
    }
}

private enum SystemProfiler: CommandLineCommandExecuter {
    typealias Error = CommandLineError

    static var launchPath = "/usr/sbin/system_profiler"

    static func listDeveloperTools() async throws -> [DeveloperTool] {
        let tools: DeveloperToolsList = try await executeJSON(.listDeveloperTools())
        return tools.list
    }
}

private extension SystemProfiler {
    struct Command: CommandLineCommand {
        let arguments: [String]
        var environmentOverrides: [String: String]? { nil }

        private init(_ subcommand: String, arguments: [String]) {
            self.arguments = [subcommand] + arguments
        }

        /// List the available developer tools.
        static func listDeveloperTools() -> Command {
            Command("SPDeveloperToolsDataType", arguments: ["-json"])
        }
    }
}

struct DeveloperTool: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey {
        case path = "spdevtools_path"
        case version = "spdevtools_version"
    }

    static let empty = DeveloperTool(path: "", version: "")

    let path: String
    let version: String
}

// swiftlint:disable nesting
extension SystemProfiler {
    struct DeveloperToolsList: Decodable {
        private enum CodingKeys: String, CodingKey {
            case list = "SPDeveloperToolsDataType"
        }

        let list: [DeveloperTool]
    }

}
// swiftlint:enable nesting
