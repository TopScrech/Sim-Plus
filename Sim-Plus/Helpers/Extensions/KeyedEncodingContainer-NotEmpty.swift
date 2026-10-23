import Foundation

extension KeyedEncodingContainer where K: CodingKey {
    mutating func encodeIfNotEmpty(_ value: String, forKey key: KeyedEncodingContainer<K>.Key) throws {
        guard value.isNotEmpty else { return }
        try encode(value, forKey: key)
    }

    mutating func encodeIfNotEmpty(_ value: [String], forKey key: KeyedEncodingContainer<K>.Key) throws {
        guard value.count > 0 else { return }
        try encode(value, forKey: key)
    }
}
