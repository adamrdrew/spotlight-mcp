# Phase 0004: Polish and Harden

## Intent

Make the Spotlight MCP server production-ready by adding input validation, edge case handling, structured logging, and comprehensive user-facing documentation. This phase transforms the functionally complete server into a robust, observable, and easily deployable tool ready for real-world use with Claude Desktop.

## Scope

### In Scope

1. **Server capabilities metadata**: Add MCP server instructions describing available tools and capabilities to guide LLM usage
2. **Input validation**: Implement validation for all tool inputs (path normalization, limit clamping, empty query detection, invalid kind names)
3. **Edge case handling**: Handle Spotlight edge cases gracefully (zero results, unexpected MDItem attribute types, scope validation failures)
4. **Structured logging**: Integrate swift-log for observability with appropriate log levels (error, warning, info, debug)
5. **Path sanitization**: Verify and harden path handling to prevent directory traversal and enforce scope boundaries (L07)
6. **Manual integration testing**: Test the server with Claude Desktop MCP client to verify real-world behavior
7. **User documentation**: Write comprehensive README.md with installation instructions, tool descriptions, usage examples, and Claude Desktop configuration snippet

### Out of Scope

- Asynchronous query execution or cancellation
- Query caching or performance optimization
- Additional MCP tools beyond the four existing ones
- Advanced error recovery or retry logic
- Metrics collection or telemetry
- Security auditing beyond path sanitization
- Multi-scope search support

## Constraints

### Relevant Laws

- **L07** (File Path Sanitization): All file paths must be sanitized to prevent directory traversal. Verify paths are absolute and within allowed scope.
- **L08** (Minimal Result Logging): Do not log search results or sensitive file metadata. Log only operational events and errors.
- **L28** (README Completeness): README must include installation, configuration, and documentation of all tools with examples.
- **L29** (Documentation Reconciliation): Update `.ushabti/docs` to reflect any structural or behavioral changes.

### Relevant Style

- **Sandi Metz rules**: All new types ≤100 lines, methods ≤5 lines, ≤4 parameters
- **Typed throws**: All error-throwing functions use typed throws
- **Dependency injection**: swift-log Logger injected where needed, not instantiated internally
- **Swift Testing**: All new validation and logging code must have unit tests

## Acceptance Criteria

1. **Server instructions present**: Server initialization includes instructions string describing the four tools and their purposes
2. **Input validation implemented**: All tool handlers validate inputs and return descriptive errors for invalid arguments:
   - Empty query strings rejected
   - Relative paths rejected (absolute paths required)
   - File paths normalized and validated against scope
   - Limit values clamped to [1, 1000]
   - Unknown kind names rejected with list of valid kinds
3. **Edge cases handled**: Tool handlers gracefully handle:
   - Zero search results (return empty array, not error)
   - Metadata attributes with unexpected types (skip or log warning, don't crash)
   - Non-existent scope directories (clear error message)
4. **Structured logging operational**: swift-log integrated with appropriate log levels:
   - Server start/stop logged at info level
   - Tool invocations logged at debug level
   - Input validation failures logged at warning level
   - Query execution failures logged at error level
   - No search results or file metadata logged (L08 compliance)
5. **Path sanitization verified**: Path handling prevents directory traversal and enforces scope:
   - Relative paths (e.g., `../`, `./`) rejected
   - Symbolic links resolved and validated within scope
   - Paths outside declared scope rejected
6. **Claude Desktop integration tested**: Server successfully invoked from Claude Desktop config, all four tools work correctly, error messages are clear
7. **README complete**: README.md includes:
   - Project description and purpose
   - Build and installation instructions
   - All four tool descriptions with parameter details
   - Example usage for each tool
   - Claude Desktop configuration snippet (JSON)
   - Troubleshooting section
8. **Tests green**: All existing tests pass, new validation and edge case handling has unit test coverage
9. **Documentation reconciled**: `.ushabti/docs` updated to reflect any changes to tool behavior or error handling

## Risks / Notes

### Assumptions

- swift-log is the appropriate logging framework (lightweight, standard, no heavy dependencies)
- Manual Claude Desktop testing is sufficient for integration validation (no automated MCP client test harness needed yet)
- Path sanitization implementation is scoped to validation only; no filesystem sandboxing or chroot needed

### Deferred Work

- **Performance monitoring**: Logging query latency and result set sizes deferred to future phase if needed
- **Configuration file support**: Server configuration (log levels, default limits) hardcoded for now; external config deferred
- **Advanced error codes**: Using descriptive error messages for now; structured error codes deferred
- **Async logging**: Synchronous logging acceptable for now; async logging deferred until performance issue identified

### Known Tradeoffs

- **Logging verbosity**: Debug-level logging for tool invocations may be verbose; acceptable since debug logs disabled in production use
- **Path sanitization approach**: Using Foundation URL standardization; may not catch all edge cases but sufficient for trusted MCP client usage
- **README maintenance burden**: Comprehensive README requires updates when tools change; acceptable tradeoff for usability
