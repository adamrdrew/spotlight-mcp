# Spotlight MCP

A [Model Context Protocol](https://modelcontextprotocol.io/) (MCP) server that exposes macOS Spotlight search to Large Language Models. Built in Swift, runs as a single binary with no external dependencies beyond macOS.

## What It Does

Spotlight is the search engine built into every Mac — it indexes file contents, metadata, and file types across the filesystem. This server wraps that capability into four MCP tools that any LLM client can call:

| Tool | Description |
|------|-------------|
| `search` | Full-text search across file contents within a directory |
| `get_metadata` | Retrieve Spotlight metadata (type, size, dates, etc.) for a specific file |
| `search_by_kind` | Find files by type: `document`, `image`, `video`, `audio`, `pdf`, `code` |
| `recent_files` | Find files modified after a given date within a directory |

All tools return structured JSON with absolute file paths, ISO 8601 dates, and full Spotlight metadata. Search results are paginated (default 100, max 1000).

## Requirements

- **macOS** 13.0 or later
- **Swift** 6.0 or later (ships with Xcode 16+)

No other dependencies. Swift Package Manager handles the one external package (the [MCP Swift SDK](https://github.com/modelcontextprotocol/swift-sdk)).

## Quick Start

```bash
# Build
swift build

# Run tests (79 tests)
swift test

# The binary is at:
.build/debug/spotlight-mcp
```

The server communicates over stdin/stdout using JSON-RPC. You don't run it directly — an MCP client launches it as a subprocess.

## MCP Client Configuration

Point your MCP client at the built binary. The exact format depends on your client:

```json
{
  "mcpServers": {
    "spotlight": {
      "command": "/path/to/spotlight-mcp/.build/debug/spotlight-mcp"
    }
  }
}
```

For production use, build in release mode (`swift build -c release`) and use the binary at `.build/release/spotlight-mcp`.

## Tool Reference

### search

Search for files by text content within a scoped directory.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | yes | Text to search for in file contents |
| `scope` | string | yes | Absolute path to directory to search within |
| `limit` | integer | no | Max results to return (default 100, max 1000) |

### get_metadata

Get Spotlight metadata attributes for a specific file.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `path` | string | yes | Absolute path to the file |

### search_by_kind

Search for files by content type within a scoped directory.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `kind` | string | yes | One of: `document`, `image`, `video`, `audio`, `pdf`, `code` |
| `scope` | string | yes | Absolute path to directory to search within |
| `limit` | integer | no | Max results to return (default 100, max 1000) |

### recent_files

Find recently modified files within a scoped directory.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `scope` | string | yes | Absolute path to directory to search within |
| `since` | string | no | ISO 8601 date — only files modified after this (default: 7 days ago) |
| `limit` | integer | no | Max results to return (default 100, max 1000) |

## Security Model

- **Scoped searches only** — every search tool requires an explicit directory scope. No system-wide searches are permitted.
- **Read-only** — all tools are read-only (annotated with `readOnlyHint: true`). Nothing is created, modified, or deleted.
- **Absolute paths** — all file paths in responses are absolute. No relative paths are accepted or returned.
- **No elevated privileges** — the server runs with the same permissions as the user who launched it.
- **TCC boundaries respected** — Spotlight honors macOS privacy controls. If the user hasn't granted access to a directory, results from that directory won't appear.

## Development

### Building and Testing

```bash
swift build                        # Debug build
swift build -c release             # Release build
swift test                         # Run all 79 tests
swift test --filter SearchTool     # Run tests matching a name
```

### Project Structure

```
Sources/SpotlightMCP/
├── main.swift                     # Server entry point, wires everything together
├── Search/                        # Spotlight API abstraction layer
│   ├── SpotlightQuery.swift       # MDQuery execution wrapper
│   ├── QueryBuilder.swift         # Predicate construction from structured params
│   ├── MetadataItem.swift         # MDItem attribute extraction
│   ├── KindMapping.swift          # Friendly names → UTI type predicates
│   └── Types.swift                # SearchResult, MetadataValue types
└── Tools/                         # MCP tool handlers
    ├── ToolRouter.swift           # Dispatches CallTool to correct handler
    ├── SearchTool.swift           # search tool implementation
    ├── GetMetadataTool.swift      # get_metadata tool implementation
    ├── SearchByKindTool.swift     # search_by_kind tool implementation
    ├── RecentFilesTool.swift      # recent_files tool implementation
    ├── ToolSchemas.swift          # Tool definitions for ListTools
    ├── ArgumentParser.swift       # Extracts/validates MCP arguments
    ├── PaginationConfig.swift     # Result limit enforcement
    ├── ResultFormatter.swift      # JSON serialization of results
    └── ToolError.swift            # Typed error enum

Tests/SpotlightMCPTests/
├── Search/                        # Unit + integration tests for search layer
└── Tools/                         # Unit tests for tool handlers
```

### Code Style

This project enforces [Sandi Metz's rules](https://thoughtbot.com/blog/sandi-metz-rules-for-developers): types are capped at 100 lines, methods at 5 lines, and parameter lists at 4. It uses Swift 6 strict concurrency, typed throws, and value semantics throughout. See `.ushabti/style.md` for the full style guide.

## Technical Details

- **MCP SDK**: [modelcontextprotocol/swift-sdk](https://github.com/modelcontextprotocol/swift-sdk) v0.1.0+
- **Transport**: Stdio (JSON-RPC over stdin/stdout)
- **Swift language mode**: Swift 6 (strict concurrency)
- **Spotlight APIs**: CoreServices MDQuery/MDItem (public APIs only)
- **Output**: Single statically-linked binary, no dylibs or runtime dependencies
