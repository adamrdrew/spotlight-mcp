import Testing
import MCP
@testable import SpotlightMCP

@Suite("RecentFilesTool Tests")
struct RecentFilesToolTests {
    let tool = RecentFilesTool()

    @Test("handle throws for missing scope")
    func handleThrowsForMissingScope() {
        let args = ArgumentParser([:])
        #expect(throws: ToolError.self) {
            try tool.handle(args)
        }
    }

    @Test("handle throws for invalid date format")
    func handleThrowsForInvalidDateFormat() {
        let args = ArgumentParser([
            "scope": .string("/tmp"),
            "since": .string("not-a-date")
        ])
        #expect(throws: ToolError.self) {
            try tool.handle(args)
        }
    }

    @Test("handle executes with scope only")
    func handleExecutesWithScopeOnly() throws {
        let args = ArgumentParser(["scope": .string("/tmp")])
        let result = try tool.handle(args)
        #expect(result.isError != true)
    }

    @Test("handle executes with valid date")
    func handleExecutesWithValidDate() throws {
        let args = ArgumentParser([
            "scope": .string("/tmp"),
            "since": .string("2026-01-01T00:00:00Z"),
            "limit": .int(5)
        ])
        let result = try tool.handle(args)
        #expect(result.isError != true)
    }
}
