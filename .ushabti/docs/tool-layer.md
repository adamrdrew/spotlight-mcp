# Tool Layer Documentation

## Overview

The Tool layer connects the MCP protocol to the Spotlight search engine. It implements four tools (`search`, `get_metadata`, `search_by_kind`, `recent_files`) that accept structured parameters from MCP clients, execute Spotlight queries via the Search module, and return structured JSON results.

The layer is located in `Sources/SpotlightMCP/Tools/` and consists of tool handlers, a router, argument parsing, pagination, result formatting, and error handling.

## Architecture

### Request Flow

```
MCP Client → JSON-RPC → Server (main.swift)
  → ListTools handler → ToolSchemas.all()
  → CallTool handler → ToolRouter.route()
    → Logger (log tool invocation at debug level)
    → ArgumentParser (validate args)
      → PathSanitizer (validate scope paths)
    → Tool handler (SearchTool, GetMetadataTool, etc.)
      → QueryBuilder / SpotlightQuery (Search module)
      → PaginationConfig.apply()
      → ResultFormatter.format()
    → Logger (log validation/execution errors)
    → CallTool.Result (JSON response)
```

### Design Principles

1. **Separation of Concerns**: Each tool is a standalone struct with a single `handle` method
2. **Value Semantics**: All types are immutable structs conforming to `Sendable`
3. **Typed Throws**: All error paths use `ToolError` with typed throws
4. **Dependency Injection**: `QueryBuilder` is injected into tool handlers via initializers

## Components

### ToolRouter

**Location**: `Sources/SpotlightMCP/Tools/ToolRouter.swift`

Routes `CallTool.Parameters` to the appropriate tool handler based on the `name` field. Returns structured error for unknown tool names. Logs tool invocations at debug level and errors at warning/error levels.

```swift
struct ToolRouter: Sendable {
    init(logger: Logger)
    func route(_ params: CallTool.Parameters) -> CallTool.Result
}
```

**Logging behavior**:
- Tool invocations logged at `debug` level (complies with L08 — no result data)
- Validation failures (missing/invalid arguments) logged at `warning` level
- Execution failures logged at `error` level

### Tool Handlers

Each tool handler is a struct with a `handle(_ args: ArgumentParser) throws(ToolError) -> CallTool.Result` method.

#### SearchTool

**Location**: `Sources/SpotlightMCP/Tools/SearchTool.swift`

Executes natural language text search using `QueryBuilder.naturalText()`. Accepts `query`, `scope`, and optional `limit`.

#### GetMetadataTool

**Location**: `Sources/SpotlightMCP/Tools/GetMetadataTool.swift`

Retrieves Spotlight metadata for a specific file using `MDItemCreate`. Validates the path is absolute and the file exists. Accepts `path`.

#### SearchByKindTool

**Location**: `Sources/SpotlightMCP/Tools/SearchByKindTool.swift`

Searches for files by content type using `QueryBuilder.kind()` and UTI mapping. Accepts `kind`, `scope`, and optional `limit`. Supported kinds: document, image, video, audio, pdf, code. Returns descriptive error with list of valid kinds when unknown kind provided.

#### RecentFilesTool

**Location**: `Sources/SpotlightMCP/Tools/RecentFilesTool.swift`

Finds recently modified files using `QueryBuilder.modifiedSince()` with MDQuery `$time.iso()` syntax. Accepts `scope`, optional `since` (ISO 8601 date, defaults to 7 days ago), and optional `limit`.

### ArgumentParser

**Location**: `Sources/SpotlightMCP/Tools/ArgumentParser.swift`

Extracts and validates tool arguments from `[String: Value]` dictionaries received from MCP. Enforces input validation rules per L07.

```swift
struct ArgumentParser: Sendable {
    init(_ arguments: [String: Value]?)
    func requireString(_ key: String) throws(ToolError) -> String
    func requireAbsolutePath(_ key: String) throws(ToolError) -> String
    func requireValidatedScope(_ key: String) throws(ToolError) -> String
    func optionalString(_ key: String) -> String?
    func optionalInt(_ key: String) -> Int?
}
```

**Validation rules**:
- `requireString`: Rejects empty strings
- `requireAbsolutePath`: Rejects relative paths (must start with `/`)
- `requireValidatedScope`: Validates absolute path, checks directory exists via PathSanitizer

### PaginationConfig

**Location**: `Sources/SpotlightMCP/Tools/PaginationConfig.swift`

Enforces result set limits. Default: 100, maximum: 1000. Values are clamped to [1, 1000].

```swift
struct PaginationConfig: Sendable {
    init(requested: Int?)
    func apply<T>(to results: [T]) -> [T]
}
```

### ResultFormatter

**Location**: `Sources/SpotlightMCP/Tools/ResultFormatter.swift`

Formats `[SearchResult]` and `[String: MetadataValue]` as JSON text content for MCP responses. Uses ISO 8601 date encoding and sorted keys.

```swift
struct ResultFormatter {
    static func format(_ results: [SearchResult]) -> Tool.Content
    static func format(_ metadata: [String: MetadataValue]) -> Tool.Content
}
```

### PathSanitizer

**Location**: `Sources/SpotlightMCP/Tools/PathSanitizer.swift`

Sanitizes and validates file paths per L07 (Path Sanitization). Resolves symbolic links and enforces scope boundaries.

```swift
struct PathSanitizer: Sendable {
    func sanitize(_ path: String, within scope: String) throws(ToolError) -> URL
    func validateScope(_ scope: String) throws(ToolError)
}
```

**Validation rules**:
- Resolves symbolic links using `URL.resolvingSymlinksInPath()`
- Validates resolved paths are within declared scope
- Validates scope directories exist and are directories (not files)

### ToolError

**Location**: `Sources/SpotlightMCP/Tools/ToolError.swift`

Typed error enum for tool-layer failures.

```swift
enum ToolError: Error, Equatable, Sendable {
    case unknownTool(String)
    case missingArgument(String)
    case invalidArgument(String)
    case fileNotFound(String)
    case queryFailed(String)
}
```

### ToolSchemas

**Location**: `Sources/SpotlightMCP/Tools/ToolSchemas.swift`, `ToolSchemas+Definitions.swift`

Defines the four MCP tool schemas with names, descriptions, input parameter JSON schemas, and `readOnlyHint` annotations. Split across two files to stay under the 100-line Sandi Metz limit.

## Tool Input Schemas

### search
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | yes | Text to search for in file contents |
| scope | string | yes | Absolute path to directory to search within |
| limit | integer | no | Maximum results (default 100, max 1000) |

### get_metadata
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| path | string | yes | Absolute path to the file |

### search_by_kind
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| kind | string | yes | File kind: document, image, video, audio, pdf, code |
| scope | string | yes | Absolute path to directory to search within |
| limit | integer | no | Maximum results (default 100, max 1000) |

### recent_files
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| scope | string | yes | Absolute path to directory to search within |
| since | string | no | ISO 8601 date; files modified after this (default: 7 days ago) |
| limit | integer | no | Maximum results (default 100, max 1000) |

## Law Compliance

| Law | How Enforced |
|-----|-------------|
| L04 (No Raw Query) | Tools accept only structured parameters |
| L05 (Explicit Scope) | All search tools require `scope` parameter |
| L07 (Path Sanitization) | PathSanitizer resolves symlinks, validates scope boundaries; all tools use requireValidatedScope |
| L08 (Minimal Logging) | ToolRouter logs only operational events, not search results or file metadata |
| L09 (Structured JSON) | ResultFormatter produces JSON; never raw strings |
| L10 (Pagination) | PaginationConfig enforces default 100, max 1000 |
| L11 (ISO 8601) | ISO8601DateFormatter for dates; JSONEncoder with `.iso8601` |
| L12 (Absolute Paths) | SearchResult.path from MDItem is always absolute |
| L15 (Result Limits) | Documented in schemas and enforced by PaginationConfig |
| L18 (Typed Throws) | All handlers use `throws(ToolError)` |

## Testing

### Unit Tests

**Location**: `Tests/SpotlightMCPTests/Tools/`

| Test File | Coverage |
|-----------|----------|
| ArgumentParserTests.swift | requireString, requireAbsolutePath, requireValidatedScope, optionalString, optionalInt, nil handling |
| PathSanitizerTests.swift | Path resolution, symlink validation, scope boundary enforcement, directory validation |
| PaginationConfigTests.swift | default/max/min limits, apply truncation |
| ResultFormatterTests.swift | JSON array/object formatting, empty results |
| ToolErrorTests.swift | Error message formatting for all cases |
| ToolRouterTests.swift | Routing to all tools, unknown tool error, logger injection |
| SearchToolTests.swift | Valid execution, missing query/scope errors |
| GetMetadataToolTests.swift | Valid file, missing/relative/nonexistent path errors |
| SearchByKindToolTests.swift | Valid execution, missing kind/scope, unknown kind errors with valid kinds list |
| RecentFilesToolTests.swift | Valid execution, missing scope, invalid date errors |

## Related Documentation

- [Search Module](search-module.md) — Spotlight query engine (QueryBuilder, SpotlightQuery, MetadataItem)
- **Project Laws**: `.ushabti/laws.md`
- **Style Guide**: `.ushabti/style.md`
