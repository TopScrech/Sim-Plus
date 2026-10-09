import Foundation

/**
 FYI: Using Swift 5.3 it's possible to abstract also the error with something like this
 ```
 protocol CommandLineErrorRepresentable: Error {
     static var missingCommand: Self { get }
     static var missingOutput: Self { get }
     static func unknown(_ error: Error) -> Self
 }

 enum CommandLineCommandExecuterError: CommandLineErrorRepresentable
    case missingCommand
    case missingOutput
    case unknownError(Error)
 }

 protocol CommandLineCommandExecuter {
    ...
    associatedtype CommandLineError: CommandLineErrorRepresentable = CommandLineCommandExecuterError
    ...

    static func execute(_ arguments: [String], completion: @escaping (Result<Data, CommandLineError>) -> Void) {
        ....
    }
 }
 ```
 */
enum CommandLineError: Error {
    case missingCommand
    case missingOutput
    case unknown(Swift.Error)
}

protocol CommandLineCommand {
    var command: String? { get }
    var arguments: [String] { get }
    var environmentOverrides: [String: String]? { get }
}

protocol CommandLineCommandExecuter {
    associatedtype Command: CommandLineCommand
    static var launchPath: String { get }
}

extension CommandLineCommand {
    var command: String? { nil }
}

extension CommandLineCommandExecuter {

    static func executeData(_ command: Command) async throws -> Data {
        let executable = command.command ?? launchPath
        let arguments = command.arguments
        let environmentOverrides = command.environmentOverrides

        return try await Task.detached(priority: .userInitiated) {
            guard let data = Process.execute(executable, arguments: arguments, environmentOverrides: environmentOverrides) else {
                throw CommandLineError.missingCommand
            }
            return data
        }.value
    }

    static func executeAsync(_ command: Command) -> Process {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = command.arguments

        let pipe = Pipe()
        task.standardOutput = pipe

        try? task.run()
        return task
    }

    static func execute(_ command: Command, completion: ((Result<Data, CommandLineError>) -> Void)? = nil) {
        Task { @MainActor in
            do {
                let data = try await executeData(command)
                completion?(.success(data))
            } catch {
                completion?(.failure(error as? CommandLineError ?? .unknown(error)))
            }
        }
    }

    static func executeJSON<T: Decodable>(_ command: Command) async throws -> T {
        let data = try await executeData(command)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw CommandLineError.missingOutput
        }
    }

    static func executePropertyList<T: Decodable>(_ command: Command) async throws -> T {
        let data = try await executeData(command)
        do {
            return try PropertyListDecoder().decode(T.self, from: data)
        } catch {
            throw CommandLineError.missingOutput
        }
    }
}
