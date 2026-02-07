import MCP

let server = Server(
    name: "spotlight-mcp",
    version: "0.1.0",
    capabilities: .init(
        tools: .init()
    )
)

let router = ToolRouter()

await server.withMethodHandler(ListTools.self) { _ in
    .init(tools: ToolSchemas.all())
}

await server.withMethodHandler(CallTool.self) { params in
    router.route(params)
}

let transport = StdioTransport()

try await server.start(transport: transport)

await server.waitUntilCompleted()
