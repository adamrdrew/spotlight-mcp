import Testing
import MCP
@testable import SpotlightMCP

@Suite("SearchTool Tests")
struct SearchToolTests {
    let tool = SearchTool()

    @Test("handle throws for missing query")
    func handleThrowsForMissingQuery() {
        let args = ArgumentParser(["scope": .string("/tmp")])
        #expect(throws: ToolError.self) {
            try tool.handle(args)
        }
    }

    @Test("handle throws for missing scope")
    func handleThrowsForMissingScope() {
        let args = ArgumentParser(["query": .string("test")])
        #expect(throws: ToolError.self) {
            try tool.handle(args)
        }
    }

    @Test("handle executes with valid arguments")
    func handleExecutesWithValidArguments() throws {
        let args = ArgumentParser([
            "query": .string("swift"),
            "scope": .string("/tmp"),
            "limit": .int(5)
        ])
        let result = try tool.handle(args)
        #expect(result.isError != true)
    }
}
