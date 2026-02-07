import Testing
import MCP
@testable import SpotlightMCP

@Suite("SearchByKindTool Tests")
struct SearchByKindToolTests {
    let tool = SearchByKindTool()

    @Test("handle throws for missing kind")
    func handleThrowsForMissingKind() {
        let args = ArgumentParser(["scope": .string("/tmp")])
        #expect(throws: ToolError.self) {
            try tool.handle(args)
        }
    }

    @Test("handle throws for missing scope")
    func handleThrowsForMissingScope() {
        let args = ArgumentParser(["kind": .string("image")])
        #expect(throws: ToolError.self) {
            try tool.handle(args)
        }
    }

    @Test("handle throws for unknown kind")
    func handleThrowsForUnknownKind() {
        let args = ArgumentParser([
            "kind": .string("spreadsheet"),
            "scope": .string("/tmp")
        ])
        #expect(throws: ToolError.self) {
            try tool.handle(args)
        }
    }

    @Test("handle executes with valid arguments")
    func handleExecutesWithValidArguments() throws {
        let args = ArgumentParser([
            "kind": .string("code"),
            "scope": .string("/tmp"),
            "limit": .int(5)
        ])
        let result = try tool.handle(args)
        #expect(result.isError != true)
    }
}
