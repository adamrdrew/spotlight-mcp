# Phase 0003: Tool Wiring - Connect MCP Tools to Spotlight Engine

## Intent

Connect the MCP tool handlers to the Spotlight query engine built in Phase 2. This phase implements four functional tools: `search`, `get_metadata`, `search_by_kind`, and `recent_files`. Each tool parses MCP request arguments, delegates to the Spotlight query layer, formats results as structured JSON, and handles errors gracefully.

This phase completes the vertical integration of the MCP server, making it capable of serving real Spotlight queries to LLM clients.

## Scope

### In Scope

- Implement `search` tool handler (parse query and scope, execute, format results)
- Implement `get_metadata` tool handler (parse file path, create MDItem, return attributes)
- Implement `search_by_kind` tool handler (map kind to UTI predicate, combine filters, execute)
- Implement `recent_files` tool handler (build date predicate, execute with scope)
- Define tool schemas in ListTools with input parameters and descriptions
- Route CallTool requests to correct handler based on tool name
- Error handling for invalid arguments, missing files, and query failures
- Basic pagination via `limit` parameter (default 100, max 1000)
- Manual end-to-end verification via JSON-RPC calls

### Out of Scope

- Path sanitization implementation (basic validation only - comprehensive sanitization deferred to security phase)
- Complex query combination logic (AND/OR across multiple criteria)
- Query result caching or optimization
- Asynchronous execution with progress updates
- Configurable timeout infrastructure (use simple default timeouts)
- Cursor-based pagination (offset-based is acceptable for initial implementation)
- Automated integration test suite (deferred to testing phase)
- Comprehensive error recovery and retry logic

## Constraints

### Laws

- **L04 (No Raw Query Construction Exposure)**: Tools must accept only structured parameters (e.g., `query`, `kind`, `scope`). No raw predicate strings exposed to MCP clients.
- **L05 (Explicit Search Scope Required)**: All search operations must require explicit scope parameter. No system-wide searches permitted.
- **L07 (File Path Sanitization)**: File path inputs must be validated (note: full sanitization deferred, but validation required to prevent obviously invalid paths).
- **L09 (Structured JSON Responses)**: All tools return structured JSON, never raw strings.
- **L10 (Mandatory Pagination)**: All search operations must support `limit` parameter. Default limit is 100, maximum is 1000.
- **L11 (ISO 8601 DateTime Format)**: Date parameters and date values in responses must use ISO 8601 format.
- **L12 (Absolute File Paths Only)**: All file paths in responses must be absolute.
- **L14 (Query Timeout Enforcement)**: Search operations must enforce timeouts (use simple default for this phase).
- **L15 (Result Set Limits Documented and Enforced)**: Each tool must document and enforce maximum result counts.
- **L18 (Typed Throws)**: Error handling must use typed throws.
- **L20 (Public Method Test Coverage)**: Every public method must have at least one test (manual tests acceptable for this phase).

### Style

- **Sandi Metz Rules**: Types ≤ 100 lines, methods ≤ 5 lines, parameters ≤ 4
- **Protocol-Oriented Programming**: Define tool handler protocol for abstraction
- **Value Semantics**: Use structs for parameter and result types
- **Dependency Injection**: Pass query engine and builder as dependencies
- **Functional Patterns**: Use map/compactMap for result transformation

## Acceptance Criteria

1. **ListTools Returns Four Tools**: `tools/list` request returns all four tool definitions with names, descriptions, and input schemas.
2. **Search Tool Works**: `search` tool accepts `query` and `scope` parameters, executes Spotlight query, returns structured results with file paths and metadata.
3. **Get Metadata Tool Works**: `get_metadata` tool accepts `path` parameter, returns metadata dictionary for the file.
4. **Search By Kind Tool Works**: `search_by_kind` tool accepts `kind` and `scope` parameters, executes kind-filtered query, returns results.
5. **Recent Files Tool Works**: `recent_files` tool accepts `scope` and optional `since` parameter (ISO 8601 date), returns recently modified files.
6. **Pagination Enforced**: All search tools respect `limit` parameter. Default is 100, maximum is 1000. Results are truncated if necessary.
7. **Absolute Paths**: All file paths in responses are absolute (verified by inspecting response JSON).
8. **Error Handling**: Invalid arguments (e.g., missing scope, invalid path, bad date format) produce structured error responses with `isError: true` and descriptive messages.
9. **Tool Routing Works**: CallTool correctly routes to appropriate handler based on tool name. Unknown tool names return error response.
10. **Manual Test Passes**: Manual end-to-end test confirms all four tools work via JSON-RPC: start server, send `initialize`, send `tools/list`, call each tool, verify responses.

## Risks / Notes

- **Path Sanitization Deferred**: This phase validates paths but does not implement comprehensive sanitization (e.g., resolving symlinks, preventing directory traversal). Full sanitization is deferred to a dedicated security phase. Basic validation (non-empty, absolute path format) is acceptable here.
- **Manual Testing Only**: Automated integration tests are deferred to a future testing phase. Manual JSON-RPC tests via stdio are acceptable for verification.
- **Simple Timeout Defaults**: This phase uses simple default timeouts for query execution. Configurable timeout infrastructure is deferred.
- **Offset-Based Pagination**: Cursor-based pagination is more robust for large result sets but adds complexity. Offset-based pagination (via `limit` parameter) is acceptable for initial implementation.
- **No Query Caching**: Query result caching is deferred. Each tool invocation executes a fresh Spotlight query.
- **Metadata Extraction for get_metadata**: The `get_metadata` tool must create an MDItem from a file path. This requires verifying the file exists and is indexed by Spotlight. If not indexed, return appropriate error.
