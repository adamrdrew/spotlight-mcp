# Steps

## S001: Define Tool Schemas

**Intent**: Define the four MCP tool schemas with input parameters, types, and descriptions. This provides the contract for each tool.

**Work**:
- Create tool schema definitions for `search`, `get_metadata`, `search_by_kind`, and `recent_files`
- Define input parameters for each tool (query, scope, kind, path, since, limit)
- Document parameter types, required vs. optional, and descriptions
- Ensure schemas conform to MCP protocol requirements

**Done when**: Tool schema definitions exist and are registered in ListTools handler. Sending `tools/list` returns all four tools with complete input schemas.

---

## S002: Implement Search Tool Handler

**Intent**: Implement the `search` tool to execute natural language text searches with explicit scope.

**Work**:
- Parse `query` (string), `scope` (string path), and `limit` (optional int) from request arguments
- Validate scope parameter is non-empty
- Use QueryBuilder to create text predicate
- Execute SpotlightQuery with scope
- Format results as structured JSON (array of objects with `path` and `metadata`)
- Handle errors (invalid scope, query failure)

**Done when**: Calling `search` tool via CallTool executes Spotlight text search and returns structured results. Invalid arguments produce error responses.

---

## S003: Implement Get Metadata Tool Handler

**Intent**: Implement the `get_metadata` tool to retrieve metadata for a specific file path.

**Work**:
- Parse `path` (string) from request arguments
- Validate path is non-empty and absolute
- Create URL from path and verify file exists
- Create MDItem for the file path
- Use MetadataItem to extract all attributes
- Format metadata as structured JSON dictionary
- Handle errors (invalid path, file not found, file not indexed)

**Done when**: Calling `get_metadata` tool via CallTool returns metadata dictionary for a valid file path. Invalid paths or non-indexed files produce error responses.

---

## S004: Implement Search By Kind Tool Handler

**Intent**: Implement the `search_by_kind` tool to search for files by content type (e.g., "document", "image").

**Work**:
- Parse `kind` (string), `scope` (string path), and `limit` (optional int) from request arguments
- Validate kind and scope parameters are non-empty
- Use QueryBuilder.kind to map kind to UTI predicate
- Execute SpotlightQuery with kind predicate and scope
- Format results as structured JSON
- Handle errors (unknown kind, invalid scope, query failure)

**Done when**: Calling `search_by_kind` tool via CallTool executes kind-filtered search and returns results. Unknown kinds or invalid scope produce error responses.

---

## S005: Implement Recent Files Tool Handler

**Intent**: Implement the `recent_files` tool to search for recently modified files with optional date filtering.

**Work**:
- Parse `scope` (string path), `since` (optional ISO 8601 date string), and `limit` (optional int) from request arguments
- Validate scope parameter is non-empty
- Parse `since` parameter if provided (ISO 8601 format)
- Build date predicate using kMDItemContentModificationDate
- Execute SpotlightQuery with date predicate and scope
- Format results as structured JSON
- Handle errors (invalid scope, invalid date format, query failure)

**Done when**: Calling `recent_files` tool via CallTool executes date-filtered search and returns results. Invalid date formats or scope produce error responses.

---

## S006: Implement CallTool Routing Logic

**Intent**: Route CallTool requests to the appropriate tool handler based on tool name.

**Work**:
- Update CallTool handler to inspect request tool name
- Route to search, get_metadata, search_by_kind, or recent_files handler
- Return structured error for unknown tool names
- Ensure routing logic delegates to tool-specific handlers
- Preserve error context for debugging

**Done when**: CallTool handler correctly routes requests to all four tool handlers. Unknown tool names return structured error response.

---

## S007: Add Pagination and Result Limits

**Intent**: Enforce pagination limits on search results to comply with L10 and L15.

**Work**:
- Parse `limit` parameter from tool arguments (default 100, max 1000)
- Validate limit is within acceptable range (1-1000)
- Truncate result arrays to limit before returning
- Document default and maximum limits in tool schemas
- Update tool handlers to apply limit to results

**Done when**: All search tools respect limit parameter. Results are truncated if necessary. Tool schemas document default and max limits.

---

## S008: Add Error Handling and Validation

**Intent**: Ensure all tools handle invalid arguments gracefully with structured error responses.

**Work**:
- Validate required parameters are present and non-empty
- Validate paths are absolute and exist (for get_metadata)
- Validate date formats are ISO 8601 (for recent_files)
- Catch query errors and format as MCP error responses
- Return descriptive error messages with `isError: true`
- Ensure no uncaught exceptions escape handlers

**Done when**: All tools validate inputs and return structured error responses for invalid arguments. No crashes or uncaught exceptions.

---

## S009: End-to-End Manual Test

**Intent**: Verify all tools work correctly via manual JSON-RPC interaction.

**Work**:
- Start the MCP server via stdio
- Send `initialize` request and verify response
- Send `tools/list` request and verify all four tools are listed
- Call `search` tool with valid query and scope, verify results
- Call `get_metadata` tool with valid file path, verify metadata
- Call `search_by_kind` tool with valid kind and scope, verify results
- Call `recent_files` tool with valid scope and optional date, verify results
- Test error cases (invalid scope, missing parameters, bad date format)
- Document test procedure and results

**Done when**: Manual test confirms all four tools work as expected. Test procedure is documented in phase notes or review file.

---

## S010: Fix QueryBuilder.naturalText Test Failure

**Intent**: Resolve the discrepancy between QueryBuilder.naturalText implementation and test expectations.

**Work**:
- Review intended behavior: wildcard matching (==) vs CONTAINS operator
- Update either implementation or test to match intended behavior
- Update search-module.md documentation to reflect actual behavior
- Verify all existing uses of naturalText work correctly with chosen approach
- Re-run all tests to confirm fix

**Done when**: All QueryBuilder tests pass. Documentation matches implementation.

---

## S011: Add Automated Tool Handler Tests

**Intent**: Provide automated test coverage for all public tool handler methods to comply with L20.

**Work**:
- Create Tests/SpotlightMCPTests/Tools/ directory
- Create SearchToolTests.swift with tests for SearchTool.handle (success, invalid args, query failure)
- Create GetMetadataToolTests.swift with tests for GetMetadataTool.handle (success, missing file, invalid path)
- Create SearchByKindToolTests.swift with tests for SearchByKindTool.handle (success, unknown kind, invalid scope)
- Create RecentFilesToolTests.swift with tests for RecentFilesTool.handle (success, invalid date, missing scope)
- Create ToolRouterTests.swift with tests for routing and unknown tool handling
- Create ArgumentParserTests.swift with tests for all argument extraction methods
- Create PaginationConfigTests.swift with tests for limit clamping and result truncation
- Create ResultFormatterTests.swift with tests for JSON formatting of results and metadata

**Done when**: All public methods in tool handlers have at least one automated test. All tests pass.

---

## S012: Document Manual Test Execution

**Intent**: Record manual test procedure and results to verify acceptance criterion 10.

**Work**:
- Create manual-test.md in phase directory documenting:
  - Test environment setup (how to build and run server)
  - Test procedure for each tool (exact JSON-RPC requests sent)
  - Expected responses for each test case
  - Actual responses observed
  - Error case testing (invalid arguments, missing parameters)
  - Test execution date and environment details

**Done when**: Manual test procedure is documented with evidence of execution. All four tools verified to work correctly via JSON-RPC.

---

## S013: Reconcile Documentation with Tool Layer

**Intent**: Document the tool integration layer to comply with L29.

**Work**:
- Create .ushabti/docs/tool-layer.md documenting:
  - Tool handler architecture and responsibilities
  - Tool routing mechanism (ToolRouter dispatch logic)
  - Pagination configuration and enforcement
  - Error handling strategy (ToolError enum and propagation)
  - Result formatting (ResultFormatter JSON serialization)
  - Argument parsing and validation (ArgumentParser)
  - Integration with search module (QueryBuilder usage)
- Update .ushabti/docs/index.md to reference tool-layer.md
- Document tool schemas and MCP protocol integration

**Done when**: Documentation covers all tool layer components introduced in Phase 0003. Docs are accurate and complete.
