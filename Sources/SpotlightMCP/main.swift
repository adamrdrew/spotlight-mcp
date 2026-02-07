import MCP
import Logging

var logger = Logger(label: "com.spotlight-mcp.server")
logger.logLevel = .info

logger.info("Starting Spotlight MCP server")

let server = Server(
    name: "spotlight-mcp",
    version: "0.1.0",
    instructions: """
    This server provides macOS Spotlight search capabilities through four tools:

    1. search: Perform text-based Spotlight searches within a specified directory scope. \
    Use for finding files by content or name.

    2. search_by_kind: Search for files by type (documents, images, code, etc.) \
    within a specified directory scope. Use when filtering by file category.

    3. get_metadata: Retrieve detailed metadata for a specific file path. \
    Use to inspect file properties like size, dates, and content type.

    4. recent_files: Find recently modified files within a specified directory scope. \
    Use for discovering recent activity or changes.

    All search operations require an explicit scope parameter (directory path) for privacy and performance.
    """,
    capabilities: .init(
        tools: .init()
    )
)

let router = ToolRouter(logger: logger)

await server.withMethodHandler(ListTools.self) { _ in
    .init(tools: ToolSchemas.all())
}

await server.withMethodHandler(CallTool.self) { params in
    router.route(params)
}

let transport = StdioTransport()

try await server.start(transport: transport)

logger.info("Server started successfully")

await server.waitUntilCompleted()

logger.info("Server shutdown complete")
