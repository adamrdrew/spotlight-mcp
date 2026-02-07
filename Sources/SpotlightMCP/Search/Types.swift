import Foundation

/// Represents a single search result from Spotlight.
public struct SearchResult: Equatable, Codable, Sendable {
    public let path: URL
    public let metadata: [String: MetadataValue]

    public init(
        path: URL,
        metadata: [String: MetadataValue]
    ) {
        self.path = path
        self.metadata = metadata
    }
}

/// Represents a metadata value that can be serialized to JSON.
public enum MetadataValue: Equatable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case date(Date)
    case array([MetadataValue])
    case dictionary([String: MetadataValue])
}
