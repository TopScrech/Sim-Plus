import Foundation

struct Snapshot: Equatable, Hashable, Identifiable {
    let id: String
    let creationDate: Date
    let size: Int

    static func == (lhs: Snapshot, rhs: Snapshot) -> Bool {
        lhs.id == rhs.id
    }
}
