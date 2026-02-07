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
public enum MetadataValue: Equatable, Codable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case date(Date)
    case array([MetadataValue])
    case dictionary([String: MetadataValue])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = try Self.decodeValue(from: container, decoder: decoder)
    }

    private static func decodeValue(from container: SingleValueDecodingContainer, decoder: Decoder) throws -> MetadataValue {
        if let value = try? decodeSimpleType(from: container) {
            return value
        }
        return try decodeComplexType(from: container, decoder: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try encodeValue(to: &container)
    }

    private static func decodeSimpleType(from container: SingleValueDecodingContainer) throws -> MetadataValue? {
        if let string = try? container.decode(String.self) {
            return .string(string)
        }
        return try decodeNumericOrDate(from: container)
    }

    private static func decodeNumericOrDate(from container: SingleValueDecodingContainer) throws -> MetadataValue? {
        if let int = try? container.decode(Int.self) {
            return .int(int)
        }
        return try decodeDoubleOrDate(from: container)
    }

    private static func decodeDoubleOrDate(from container: SingleValueDecodingContainer) throws -> MetadataValue? {
        if let double = try? container.decode(Double.self) {
            return .double(double)
        }
        return decodeDate(from: container)
    }

    private static func decodeDate(from container: SingleValueDecodingContainer) -> MetadataValue? {
        guard let date = try? container.decode(Date.self) else {
            return nil
        }
        return .date(date)
    }

    private static func decodeComplexType(from container: SingleValueDecodingContainer, decoder: Decoder) throws -> MetadataValue {
        if let array = try? container.decode([MetadataValue].self) {
            return .array(array)
        }
        return try decodeDict(from: container, decoder: decoder)
    }

    private static func decodeDict(from container: SingleValueDecodingContainer, decoder: Decoder) throws -> MetadataValue {
        if let dict = try? container.decode([String: MetadataValue].self) {
            return .dictionary(dict)
        }
        throw createDecodingError(decoder: decoder)
    }

    private static func createDecodingError(decoder: Decoder) -> DecodingError {
        let context = createContext(decoder: decoder)
        return DecodingError.dataCorrupted(context)
    }

    private static func createContext(decoder: Decoder) -> DecodingError.Context {
        DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Unable to decode MetadataValue"
        )
    }

    private func encodeValue(to container: inout SingleValueEncodingContainer) throws {
        guard case .string(let value) = self else {
            return try encodeNonString(to: &container)
        }
        try container.encode(value)
    }

    private func encodeNonString(to container: inout SingleValueEncodingContainer) throws {
        if case .int(let value) = self {
            try container.encode(value)
        } else {
            try encodeDoubleOrComplex(to: &container)
        }
    }

    private func encodeDoubleOrComplex(to container: inout SingleValueEncodingContainer) throws {
        if case .double(let value) = self {
            try container.encode(value)
        } else {
            try encodeComplex(to: &container)
        }
    }

    private func encodeComplex(to container: inout SingleValueEncodingContainer) throws {
        if case .date(let value) = self {
            try container.encode(value)
        } else {
            try encodeCollection(to: &container)
        }
    }

    private func encodeCollection(to container: inout SingleValueEncodingContainer) throws {
        if case .array(let value) = self {
            try container.encode(value)
        } else if case .dictionary(let value) = self {
            try container.encode(value)
        }
    }
}
