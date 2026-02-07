# Steps for Phase 0001: Skeleton

## S001: Create Package.swift with MCP SDK Dependency

**Intent**: Establish the Swift package definition with the correct language mode and dependencies.

**Work**:
- Create `Package.swift` at repository root
- Specify Swift 6 language mode (via `swift-tools-version: 6.0` or equivalent)
- Add the Swift MCP SDK as a package dependency (determine correct repository/version)
- Define an executable product named `spotlight-mcp`
- Define a target for the executable with dependency on the MCP SDK

**Done When**:
- `Package.swift` exists and is syntactically valid
- Running `swift package resolve` succeeds and downloads dependencies
- File specifies Swift 6 tools version

## S002: Create Main Entry Point with Server Initialization

**Intent**: Implement the executable entry point that creates and starts an MCP server.

**Work**:
- Create `Sources/SpotlightMCP/main.swift`
- Import the MCP SDK module
- Instantiate an MCP server object
- Configure stdio transport for JSON-RPC communication
- Call the server's start/run method to begin listening on stdio

**Done When**:
- `main.swift` exists with a runnable main entry point
- Code compiles (may not function fully until handlers are registered)
- Server initialization code is present

## S003: Register ListTools Handler Returning Empty Array

**Intent**: Implement the MCP `tools/list` endpoint to return a valid but empty tools list.

**Work**:
- Register a handler for the `tools/list` MCP request
- Implement handler logic that returns an empty array of tools
- Ensure response conforms to MCP protocol schema for tools list

**Done When**:
- Handler is registered in the server initialization code
- Handler returns a valid JSON response with an empty tools array
- Code compiles

## S004: Register CallTool Handler with Stub Implementation

**Intent**: Implement the MCP `tools/call` endpoint with a placeholder response.

**Work**:
- Register a handler for the `tools/call` MCP request
- Implement a stub handler that either:
  - Returns a generic error (e.g., "no tools available")
  - Returns a fixed placeholder response
- Ensure response conforms to MCP protocol schema

**Done When**:
- Handler is registered in the server initialization code
- Handler returns a valid MCP response (success or error)
- Code compiles

## S005: Build and Verify Compilation

**Intent**: Ensure the package builds successfully under Swift 6.

**Work**:
- Run `swift build` from the repository root
- Address any compilation errors or warnings
- Verify that a single binary is produced in `.build/debug/` or `.build/release/`

**Done When**:
- `swift build` exits with code 0 (success)
- No compiler errors or warnings
- Executable binary exists at expected path

## S006: Manual Test of MCP Protocol Handshake

**Intent**: Verify that the server responds correctly to MCP protocol messages.

**Work**:
- Run the built binary (e.g., `.build/debug/spotlight-mcp`)
- Manually send a JSON-RPC `initialize` request via stdin (or use an MCP client tool)
- Verify the server responds with a valid MCP `initialize` response including server capabilities
- Send a `tools/list` request
- Verify the response contains an empty tools array

**Done When**:
- Server starts and waits for input
- Initialize request receives a valid response
- Tools list request receives a response with `[]` or equivalent empty array
- Server does not crash or hang
- Manual verification documented (can be a brief note in progress.yaml or review.md)
