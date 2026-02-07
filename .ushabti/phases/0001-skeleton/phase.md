# Phase 0001: Skeleton - MCP Server with Stdio Transport

## Intent

Establish the foundational MCP server infrastructure with stdio transport. This phase creates a minimal executable that can complete the MCP protocol handshake and respond to basic protocol requests without implementing any Spotlight functionality. The goal is to verify that the Swift MCP SDK integration works, the server can start, and the basic request-response cycle functions correctly.

This is a proof-of-concept phase that establishes the scaffolding for all future tool development.

## Scope

### In Scope

- Package.swift configuration with Swift 6 language mode and MCP SDK dependency
- Main entry point that initializes and starts an MCP server
- Stdio transport configuration for JSON-RPC communication
- ListTools request handler returning an empty tools array
- CallTool request handler with a stub implementation
- Manual verification that the server starts and responds to protocol messages
- Basic build verification

### Out of Scope

- Actual Spotlight search functionality
- Concrete tool implementations
- Automated test suite (deferred to subsequent phases)
- Comprehensive error handling and recovery logic
- Logging infrastructure
- Configuration management
- Documentation updates (minimal skeleton documentation is acceptable)

## Constraints

### Laws

- **L01 (Swift 6 Language Level)**: Package.swift must specify Swift 6 language mode. All code must compile under Swift 6 strictness.
- **L18 (Typed Throws)**: If error handling is implemented, use typed throws.
- **L19 (Swift Testing Framework)**: When tests are added in future phases, use Swift Testing framework.
- **L25 (Single Binary Output)**: Build must produce a single executable binary.

### Style

- **Sandi Metz Rules**: All types ≤ 100 lines, methods ≤ 5 lines, parameters ≤ 4
- **Swift Package Manager**: Use SPM for dependency management
- **Dependency Injection**: Pass collaborators via initializers where applicable
- **Protocol-Oriented Programming**: Use protocols for abstraction boundaries where appropriate

## Acceptance Criteria

1. **Build Success**: `swift build` completes without errors or warnings
2. **Server Starts**: Running the built binary starts the MCP server and waits for stdio input
3. **Initialize Handshake**: Sending a valid MCP `initialize` JSON-RPC request receives a protocol-compliant response with server capabilities
4. **Tools List**: Sending a `tools/list` request returns a JSON response with an empty tools array
5. **Swift 6 Mode**: Package.swift explicitly specifies Swift 6 language mode (`swiftLanguageMode: .v6` or equivalent)
6. **Single Binary**: Build output is a single executable in `.build/debug/` or `.build/release/`

## Risks / Notes

- **Manual Testing Only**: This phase relies on manual verification. Automated tests will be added in a follow-up phase once the server structure is proven.
- **Stub CallTool**: The CallTool handler is a placeholder. It will likely error or return a fixed response. This is acceptable for this phase.
- **Minimal Error Handling**: Basic error handling is acceptable. Comprehensive error recovery is deferred.
- **MCP SDK Version**: The specific version of the Swift MCP SDK may need adjustment based on availability and API stability. If the SDK is not yet published, this phase may need to use a local or git dependency.
