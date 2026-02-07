import Testing
@testable import SpotlightMCP

@Suite("ToolError Tests")
struct ToolErrorTests {
    @Test("unknownTool message includes tool name")
    func unknownToolMessageIncludesToolName() {
        let error = ToolError.unknownTool("fake")
        #expect(error.message.contains("fake"))
    }

    @Test("missingArgument message includes argument name")
    func missingArgumentMessageIncludesArgumentName() {
        let error = ToolError.missingArgument("scope")
        #expect(error.message.contains("scope"))
    }

    @Test("invalidArgument message includes detail")
    func invalidArgumentMessageIncludesDetail() {
        let error = ToolError.invalidArgument("bad path")
        #expect(error.message.contains("bad path"))
    }

    @Test("fileNotFound message includes path")
    func fileNotFoundMessageIncludesPath() {
        let error = ToolError.fileNotFound("/missing")
        #expect(error.message.contains("/missing"))
    }

    @Test("queryFailed message includes detail")
    func queryFailedMessageIncludesDetail() {
        let error = ToolError.queryFailed("timeout")
        #expect(error.message.contains("timeout"))
    }
}
