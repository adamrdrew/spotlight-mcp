import Testing
import Foundation
import MCP
@testable import SpotlightMCP

@Suite("GetMetadataTool Tests")
struct GetMetadataToolTests {
    let tool = GetMetadataTool()

    @Test("handle throws for missing path")
    func handleThrowsForMissingPath() {
        let args = ArgumentParser([:])
        #expect(throws: ToolError.self) {
            try tool.handle(args)
        }
    }

    @Test("handle throws for relative path")
    func handleThrowsForRelativePath() {
        let args = ArgumentParser(["path": .string("relative/path")])
        #expect(throws: ToolError.self) {
            try tool.handle(args)
        }
    }

    @Test("handle throws for nonexistent file")
    func handleThrowsForNonexistentFile() {
        let args = ArgumentParser(["path": .string("/nonexistent/file.txt")])
        #expect(throws: ToolError.self) {
            try tool.handle(args)
        }
    }

    @Test("handle returns metadata for existing file")
    func handleReturnsMetadataForExistingFile() throws {
        let testFile = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Package.swift")
        let args = ArgumentParser(["path": .string(testFile.path)])
        let result = try tool.handle(args)
        #expect(result.isError != true)
        guard case .text(let text) = result.content.first else {
            Issue.record("Expected text content")
            return
        }
        #expect(text.contains("kMDItemDisplayName"))
    }
}
