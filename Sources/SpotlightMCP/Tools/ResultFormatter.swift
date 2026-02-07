import Foundation
import MCP

/// Formats search results as structured JSON for MCP tool responses.
struct ResultFormatter {
    private static let encoder = makeEncoder()

    static func format(_ results: [SearchResult]) -> Tool.Content {
        let entries = results.map(formatResult)
        return encodeEntries(entries)
    }

    static func format(_ metadata: [String: MetadataValue]) -> Tool.Content {
        encodeValue(metadata)
    }
}

extension ResultFormatter {
    private static func formatResult(_ result: SearchResult) -> [String: MetadataValue] {
        var entry = result.metadata
        entry["_path"] = .string(result.path.path)
        return entry
    }

    private static func encodeEntries(_ entries: [[String: MetadataValue]]) -> Tool.Content {
        guard let data = try? encoder.encode(entries) else {
            return .text("[]")
        }
        return .text(String(data: data, encoding: .utf8) ?? "[]")
    }

    private static func encodeValue(_ value: [String: MetadataValue]) -> Tool.Content {
        guard let data = try? encoder.encode(value) else {
            return .text("{}")
        }
        return .text(String(data: data, encoding: .utf8) ?? "{}")
    }

    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}
