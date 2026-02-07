import Testing
import Logging
import MCP
@testable import SpotlightMCP

@Suite("ToolRouter Tests")
struct ToolRouterTests {
    let router = ToolRouter(logger: Logger(label: "test"))

    @Test("routes unknown tool to error")
    func routesUnknownToolToError() {
        let params = CallTool.Parameters(name: "nonexistent")
        let result = router.route(params)
        #expect(result.isError == true)
        verifyErrorText(result, contains: "Unknown tool")
    }

    @Test("routes search tool")
    func routesSearchTool() {
        let params = CallTool.Parameters(
            name: "search",
            arguments: ["query": .string("test"), "scope": .string("/tmp")]
        )
        let result = router.route(params)
        #expect(result.isError != true)
    }

    @Test("routes get_metadata with missing path to error")
    func routesGetMetadataMissingPath() {
        let params = CallTool.Parameters(name: "get_metadata")
        let result = router.route(params)
        #expect(result.isError == true)
        verifyErrorText(result, contains: "Missing required argument")
    }

    @Test("routes search_by_kind with missing args to error")
    func routesSearchByKindMissingArgs() {
        let params = CallTool.Parameters(name: "search_by_kind")
        let result = router.route(params)
        #expect(result.isError == true)
    }

    @Test("routes recent_files with missing scope to error")
    func routesRecentFilesMissingScope() {
        let params = CallTool.Parameters(name: "recent_files")
        let result = router.route(params)
        #expect(result.isError == true)
    }

    private func verifyErrorText(_ result: CallTool.Result, contains text: String) {
        guard case .text(let msg) = result.content.first else {
            Issue.record("Expected text content")
            return
        }
        #expect(msg.contains(text))
    }
}
