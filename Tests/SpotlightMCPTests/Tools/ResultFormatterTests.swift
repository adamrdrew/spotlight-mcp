import Testing
import Foundation
import MCP
@testable import SpotlightMCP

@Suite("ResultFormatter Tests")
struct ResultFormatterTests {
    @Test("format results produces JSON array")
    func formatResultsProducesJSONArray() throws {
        let results = [
            SearchResult(
                path: URL(fileURLWithPath: "/test/file.txt"),
                metadata: ["kMDItemDisplayName": .string("file.txt")]
            )
        ]
        let content = ResultFormatter.format(results)
        let text = try extractText(content)
        #expect(text.contains("_path"))
        #expect(text.contains("file.txt"))
    }

    @Test("format results includes path as _path key")
    func formatResultsIncludesPathKey() throws {
        let results = [
            SearchResult(
                path: URL(fileURLWithPath: "/Users/test/doc.pdf"),
                metadata: [:]
            )
        ]
        let content = ResultFormatter.format(results)
        let text = try extractText(content)
        let parsed = try JSONSerialization.jsonObject(with: Data(text.utf8)) as? [[String: Any]]
        #expect(parsed?.first?["_path"] as? String == "/Users/test/doc.pdf")
    }

    @Test("format empty results produces empty array")
    func formatEmptyResultsProducesEmptyArray() throws {
        let content = ResultFormatter.format([])
        let text = try extractText(content)
        #expect(text == "[]")
    }

    @Test("format metadata produces JSON object")
    func formatMetadataProducesJSONObject() throws {
        let metadata: [String: MetadataValue] = [
            "kMDItemDisplayName": .string("test.txt"),
            "kMDItemFSSize": .int(1024)
        ]
        let content = ResultFormatter.format(metadata)
        let text = try extractText(content)
        #expect(text.contains("test.txt"))
        #expect(text.contains("1024"))
    }

    @Test("format empty metadata produces empty object")
    func formatEmptyMetadataProducesEmptyObject() throws {
        let content = ResultFormatter.format([:])
        let text = try extractText(content)
        #expect(text == "{}")
    }
}

extension ResultFormatterTests {
    private func extractText(_ content: Tool.Content) throws -> String {
        guard case .text(let text) = content else {
            Issue.record("Expected text content")
            return ""
        }
        return text
    }
}
