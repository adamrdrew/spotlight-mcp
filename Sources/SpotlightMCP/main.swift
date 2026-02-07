import MCP

let server = Server(
    name: "spotlight-mcp",
    version: "0.1.0",
    capabilities: .init(
        tools: .init()
    )
)

await server.withMethodHandler(ListTools.self) { _ in
    .init(tools: [])
}

await server.withMethodHandler(CallTool.self) { _ in
    .init(
        content: [.text("No tools available")],
        isError: true
    )
}

let transport = StdioTransport()

try await server.start(transport: transport)

await server.waitUntilCompleted()
