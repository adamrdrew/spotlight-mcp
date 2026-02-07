import Logging
import MCP

/// Routes CallTool requests to the appropriate tool handler.
struct ToolRouter: Sendable {
    private let logger: Logger
    private let searchTool = SearchTool()
    private let getMetadataTool = GetMetadataTool()
    private let searchByKindTool = SearchByKindTool()
    private let recentFilesTool = RecentFilesTool()

    init(logger: Logger) {
        self.logger = logger
    }

    func route(_ params: CallTool.Parameters) -> CallTool.Result {
        logger.debug("Tool invoked", metadata: ["tool": "\(params.name)"])
        let args = ArgumentParser(params.arguments)
        return dispatch(params.name, args)
    }

    private func dispatch(_ name: String, _ args: ArgumentParser) -> CallTool.Result {
        do {
            return try handle(name, args)
        } catch {
            logError(error, tool: name)
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

    private func logError(_ error: ToolError, tool: String) {
        switch error {
        case .missingArgument, .invalidArgument:
            logger.warning("Validation failed", metadata: ["tool": "\(tool)"])
        case .unknownTool, .fileNotFound, .queryFailed:
            logger.error("Tool execution failed", metadata: ["tool": "\(tool)"])
        }
    }

    private func errorResult(_ error: ToolError) -> CallTool.Result {
        .init(content: [.text(error.message)], isError: true)
    }
}
