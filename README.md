# Spotlight MCP

A Model Context Protocol (MCP) server that exposes macOS Spotlight functionality to Large Language Models.

## Status

This is currently a proof-of-concept skeleton implementation. The server can complete the MCP protocol handshake and respond to basic protocol requests, but does not yet implement any Spotlight search functionality.

## Requirements

- **macOS**: 13.0 or later
- **Swift**: 6.0 or later
- **Swift Package Manager**: Included with Swift

## Installation

### Building from Source

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd spotlight-mcp
   ```

2. Build the project:
   ```bash
   swift build
   ```

3. The executable will be created at `.build/debug/spotlight-mcp`

### Release Build

For optimized performance, build in release mode:
```bash
swift build -c release
```

The release binary will be at `.build/release/spotlight-mcp`

## Usage

Run the server:
```bash
.build/debug/spotlight-mcp
```

The server listens on standard input/output (stdio) for JSON-RPC messages conforming to the Model Context Protocol specification.

### MCP Client Integration

To use this server with an MCP client, configure the client to launch the `spotlight-mcp` binary as a subprocess. The server communicates via stdio transport.

Example configuration (format varies by client):
```json
{
  "mcpServers": {
    "spotlight": {
      "command": "/path/to/spotlight-mcp/.build/debug/spotlight-mcp"
    }
  }
}
```

## Current Functionality

This skeleton implementation provides:

- **MCP Protocol Support**: Responds to `initialize` requests with server capabilities
- **Stdio Transport**: JSON-RPC communication over standard input/output
- **Empty Tools List**: The `tools/list` endpoint returns an empty array (no tools implemented yet)
- **Stub Tool Call Handler**: The `tools/call` endpoint returns an error indicating no tools are available

**No Spotlight functionality is currently implemented.** This is a scaffolding phase to establish the MCP server infrastructure.

## Available MCP Tools

Currently, no tools are implemented. The server returns an empty tools list.

Future phases will implement Spotlight search tools.

## Configuration

No configuration is currently supported. Future phases will add configuration for search scopes, result limits, and other settings.

## Development

### Running Tests

Tests will be added in future phases using the Swift Testing framework:
```bash
swift test
```

### Project Structure

```
spotlight-mcp/
├── Sources/
│   └── SpotlightMCP/
│       └── main.swift          # Server entry point
├── Tests/                       # Test suite (future)
├── Package.swift                # Swift package manifest
└── README.md                    # This file
```

### Swift 6 Language Mode

This project uses Swift 6 language mode for enhanced memory safety, strict concurrency checking, and modern error handling with typed throws.

## License

[License information to be added]

## Contributing

[Contribution guidelines to be added]

## Roadmap

- [x] Phase 1: Skeleton - MCP server with stdio transport
- [ ] Future: Spotlight search tool implementation
- [ ] Future: Path sanitization and security boundaries
- [ ] Future: Result pagination and limits
- [ ] Future: Automated test suite

## Technical Details

### MCP SDK

This server uses the official Swift MCP SDK from the Model Context Protocol project:
- Repository: https://github.com/modelcontextprotocol/swift-sdk
- Version: 0.1.0 or later

### Protocol Version

The server implements MCP protocol version `2025-03-26`.

## Support

[Support information to be added]
