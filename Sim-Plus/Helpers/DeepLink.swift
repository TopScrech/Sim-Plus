import Foundation

/// A named URL with a unique identifier to make them work well with SwiftUI.
struct DeepLink: Identifiable, Codable {
    var id: UUID
    var name: String
    var url: URL
}
