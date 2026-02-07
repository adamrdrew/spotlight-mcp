# Implementation Steps

## S001: Add Server Instructions

**Intent**: Provide MCP clients (LLMs) with a description of server capabilities to guide appropriate tool usage.

**Work**:
- Add `instructions` field to Server initialization in `main.swift`
- Write concise description of the four tools and their purposes
- Ensure instructions guide LLMs to use appropriate tools for different search tasks

**Done when**:
- Server initialization includes instructions string
- Instructions accurately describe all four tools (search, get_metadata, search_by_kind, recent_files)
- Server starts successfully with instructions present

---

## S002: Add swift-log Dependency

**Intent**: Integrate structured logging framework for observability.

**Work**:
- Add swift-log dependency to Package.swift
- Import Logging in relevant source files
- Verify build succeeds with new dependency

**Done when**:
- `swift-log` listed in Package.swift dependencies
- `import Logging` compiles successfully
- `swift build` succeeds

---

## S003: Implement Input Validation

**Intent**: Validate all tool inputs and reject invalid arguments with descriptive errors.

**Work**:
- Add validation helpers to ArgumentParser or create new PathValidator type
- Validate paths are absolute (reject relative paths)
- Validate query strings are non-empty
- Validate limit values are in range [1, 1000] (clamp if needed)
- Validate kind parameter against known kinds (use KindMapping)
- Return ToolError with descriptive messages for validation failures

**Done when**:
- Empty query strings rejected with clear error
- Relative paths rejected with clear error
- Limit values clamped to [1, 1000]
- Unknown kind names rejected with list of valid kinds
- All validation errors have unit tests

---

## S004: Implement Path Sanitization

**Intent**: Prevent directory traversal and enforce scope boundaries per L07.

**Work**:
- Create PathSanitizer type or extend existing validation
- Resolve symbolic links using URL.resolvingSymlinksInPath()
- Verify resolved paths are within declared scope
- Normalize paths to absolute canonical form
- Return clear errors when paths violate scope

**Done when**:
- Relative paths (../, ./) rejected
- Symbolic links resolved and validated within scope
- Paths outside scope rejected with clear error
- Path sanitization has unit tests (mock filesystem per L24)

---

## S005: Handle Spotlight Edge Cases

**Intent**: Gracefully handle edge cases in Spotlight query results and metadata.

**Work**:
- Ensure zero-result queries return empty array (not error)
- Handle unexpected MDItem attribute types in MetadataItem (skip or log warning)
- Validate scope directories exist before query execution
- Return clear errors for non-existent scope directories

**Done when**:
- Zero-result queries return `[]` successfully
- Unexpected metadata attribute types don't crash (logged at warning level)
- Non-existent scope directories return clear error
- Edge cases have unit tests

---

## S006: Add Structured Logging

**Intent**: Add logging at appropriate levels for observability per L08.

**Work**:
- Inject Logger into Server, ToolRouter, and tool handlers
- Log server start/stop at info level
- Log tool invocations at debug level (tool name, no args/results per L08)
- Log validation failures at warning level
- Log query execution failures at error level
- Ensure no search results or file metadata logged

**Done when**:
- Logger injected via initializers (not instantiated internally)
- Server lifecycle events logged at info
- Tool invocations logged at debug
- Validation failures logged at warning
- Query failures logged at error
- No search results or sensitive data in logs (L08 compliance verified)
- Logging behavior has unit tests (verify log calls made)

---

## S007: Test Input Validation

**Intent**: Verify all validation logic works correctly with unit tests.

**Work**:
- Write tests for empty query rejection
- Write tests for relative path rejection
- Write tests for limit clamping
- Write tests for unknown kind rejection
- Ensure tests use Swift Testing framework

**Done when**:
- All validation paths have unit test coverage
- Tests verify correct error types and messages
- `swift test` passes

---

## S008: Test Path Sanitization

**Intent**: Verify path sanitization prevents directory traversal.

**Work**:
- Write tests for relative path rejection (../, ./)
- Write tests for symbolic link resolution
- Write tests for scope boundary enforcement
- Use mock filesystem per L24

**Done when**:
- Path sanitization logic has unit test coverage
- Tests verify boundary cases (paths at scope edge, outside scope)
- `swift test` passes

---

## S009: Test Edge Case Handling

**Intent**: Verify Spotlight edge cases are handled gracefully.

**Work**:
- Write test for zero-result queries
- Write test for unexpected metadata attribute types
- Write test for non-existent scope directory
- Ensure tests use Swift Testing framework

**Done when**:
- Edge case handling has unit test coverage
- Tests verify correct behavior (empty array vs. error)
- `swift test` passes

---

## S010: Test with Claude Desktop

**Intent**: Validate server works correctly with real MCP client.

**Work**:
- Build release binary (`swift build -c release`)
- Create Claude Desktop config snippet
- Add server to Claude Desktop MCP settings
- Test all four tools interactively with Claude
- Verify error messages are clear and helpful
- Document any issues or unexpected behavior

**Done when**:
- Server invoked successfully from Claude Desktop
- All four tools execute correctly
- Error messages are clear and actionable
- No crashes or unexpected failures observed

---

## S011: Write README.md

**Intent**: Provide comprehensive user-facing documentation per L28.

**Work**:
- Write project description and purpose
- Document build instructions (`swift build -c release`)
- Document installation (binary location)
- Describe all four tools with parameter details
- Provide usage examples for each tool
- Include Claude Desktop configuration snippet (JSON)
- Add troubleshooting section (common errors, solutions)

**Done when**:
- README.md exists at project root
- All required sections present (description, build, installation, tools, examples, config, troubleshooting)
- Instructions tested by following them step-by-step
- Claude Desktop config snippet is valid JSON

---

## S012: Reconcile Documentation

**Intent**: Update project documentation to reflect phase changes per L29.

**Work**:
- Review `.ushabti/docs/tool-layer.md` for accuracy
- Update if validation or error handling behavior changed
- Review `.ushabti/docs/search-module.md` for accuracy
- Update if edge case handling changed
- Ensure documentation reflects new logging infrastructure

**Done when**:
- `.ushabti/docs` reviewed and updated as needed
- Documentation accurately reflects current implementation
- No stale information present

---

## S013: Final Testing

**Intent**: Verify all tests pass and server is ready for use.

**Work**:
- Run full test suite (`swift test`)
- Build release binary (`swift build -c release`)
- Verify binary runs without errors
- Smoke test all four tools from command line or Claude Desktop

**Done when**:
- `swift test` passes (all 79+ tests green)
- `swift build -c release` succeeds
- Server starts and responds to MCP requests
- All four tools work correctly

---

## S014: Fix Sandi Metz Violations in Search Module

**Intent**: Bring Types.swift, SpotlightQuery.swift, and MetadataItem.swift into compliance with the 100-line limit.

**Work**:
- Refactor Types.swift (133 lines) to split MetadataValue Codable implementation into separate file
- Refactor SpotlightQuery.swift (108 lines) to extract 8+ lines into helper methods or extensions
- Refactor MetadataItem.swift (108 lines) to extract 8+ lines into helper methods or extensions
- Verify all 90 tests still pass after refactoring
- Verify line counts are ≤100 (excluding blanks and comments)

**Done when**:
- Types.swift ≤100 lines (excluding blanks/comments)
- SpotlightQuery.swift ≤100 lines (excluding blanks/comments)
- MetadataItem.swift ≤100 lines (excluding blanks/comments)
- All tests pass
- No functional changes, only structural refactoring

---

## S015: Document Manual Testing or Defer

**Intent**: Either document that manual Claude Desktop testing was performed, or explicitly defer it with justification.

**Work**:
- If manual testing was performed: Document tool invocations, responses, and error handling verification in progress.yaml S010 notes
- If manual testing was not performed: Update progress.yaml S010 notes to indicate testing is deferred and provide justification (e.g., "Automated tests provide sufficient coverage; manual testing deferred to user acceptance")

**Done when**:
- S010 notes in progress.yaml either:
  - Document evidence of manual testing (which tools tested, what responses observed, any issues found)
  - OR explicitly state testing is deferred with clear justification
