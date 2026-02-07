import MCP

/// Routes CallTool requests to the appropriate tool handler.
struct ToolRouter: Sendable {
    private let searchTool = SearchTool()
    private let getMetadataTool = GetMetadataTool()
    private let searchByKindTool = SearchByKindTool()
    private let recentFilesTool = RecentFilesTool()

    func route(_ params: CallTool.Parameters) -> CallTool.Result {
        let args = ArgumentParser(params.arguments)
        return dispatch(params.name, args)
    }

    private func dispatch(_ name: String, _ args: ArgumentParser) -> CallTool.Result {
        do {
            return try handle(name, args)
        } catch {
            return errorResult(error)
        }
    }

    private func handle(
        _ name: String,
        _ args: ArgumentParser
    ) throws(ToolError) -> CallTool.Result {
        switch name {
        case "search": return try searchTool.handle(args)
        case "get_metadata": return try getMetadataTool.handle(args)
        case "search_by_kind": return try searchByKindTool.handle(args)
        case "recent_files": return try recentFilesTool.handle(args)
        default: throw .unknownTool(name)
        }
    }

    private func errorResult(_ error: ToolError) -> CallTool.Result {
        .init(content: [.text(error.message)], isError: true)
    }
}
