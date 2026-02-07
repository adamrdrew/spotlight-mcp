# Implementation Steps

## S001: Understand Current Predicate Flow

**Intent**: Trace how predicates flow from `QueryBuilder` through `SpotlightQuery` to `MDQueryCreate` to understand exactly where the syntax conversion happens.

**Work**:
- Read `Sources/SpotlightMCP/Search/QueryBuilder.swift` to see how `buildTextPredicate` creates predicates
- Read `Sources/SpotlightMCP/Search/SpotlightQuery.swift` to see how it accepts predicates and passes query strings to `MDQueryCreate`
- Identify the exact point where `NSPredicate.predicateFormat` becomes the MDQuery query string (hint: line 19 in SpotlightQuery.swift)
- Document the finding in step notes

**Done when**: Step notes describe the current flow and confirm that `init(predicate:scope:)` extracts `predicateFormat` and passes it to MDQuery.

---

## S002: Fix QueryBuilder to Produce Spotlight Query String

**Intent**: Change `QueryBuilder.buildTextPredicate` to return a Spotlight-native query string instead of an NSPredicate with incompatible syntax.

**Work**:
- Change `QueryBuilder.naturalText(_ text:)` to return `String` instead of `NSPredicate`
- Implement `buildTextPredicate` to return the raw Spotlight query string: `"kMDItemTextContent == \"*\(text)*\"cd"`
- Ensure proper escaping of the text parameter to prevent injection issues (though MCP tools don't expose raw query construction, defensive coding is good practice)
- Update the return type and method signature

**Done when**: `QueryBuilder.naturalText()` returns a `String` containing Spotlight-native syntax with the `cd` suffix.

---

## S003: Update SpotlightQuery Integration

**Intent**: Ensure tool handlers pass the query string to `SpotlightQuery` using the raw string initializer path instead of the NSPredicate path.

**Work**:
- Review `Sources/SpotlightMCP/Tools/SearchTool.swift` to see how it calls `QueryBuilder.naturalText()`
- Update the tool to use `SpotlightQuery(queryString:scope:)` initializer instead of `SpotlightQuery(predicate:scope:)`
- Verify the query string flows directly to `MDQueryCreate` without NSPredicate conversion

**Done when**: `SearchTool` constructs `SpotlightQuery` using the `queryString` initializer, bypassing NSPredicate entirely for text searches.

---

## S004: Update QueryBuilder Unit Tests

**Intent**: Fix tests to expect Spotlight-native query strings instead of NSPredicate format strings.

**Work**:
- Update `Tests/SpotlightMCPTests/Search/QueryBuilderTests.swift`
- Change `naturalTextProducesTextContentPredicate` test to expect the raw Spotlight query string format
- Update `caseInsensitiveTextMatching` test to verify the `cd` suffix is present in the query string
- Remove or update assertions that check for NSPredicate-specific format (like checking `.predicateFormat`)

**Done when**: All QueryBuilder tests pass with updated expectations for `String` return type and Spotlight-native syntax.

---

## S005: Add Multi-Word Query Test

**Intent**: Verify that multi-word text searches produce correct Spotlight query strings.

**Work**:
- Add a new test `multiWordTextSearchQueryFormat` to `QueryBuilderTests.swift`
- Test that `builder.naturalText("architecture decisions")` produces `kMDItemTextContent == "*architecture decisions*"cd`
- Verify the entire phrase is wrapped in wildcards with the `cd` suffix

**Done when**: New test exists and passes, verifying multi-word queries use correct Spotlight syntax.

---

## S006: Update SearchTool Unit Tests

**Intent**: Fix SearchTool tests to work with the updated QueryBuilder signature.

**Work**:
- Review `Tests/SpotlightMCPTests/Tools/SearchToolTests.swift`
- Update any tests that may be affected by `QueryBuilder.naturalText()` returning `String` instead of `NSPredicate`
- Ensure tests still verify correct tool behavior (argument validation, result formatting, etc.)

**Done when**: All SearchTool tests pass with the updated QueryBuilder integration.

---

## S007: Run Full Test Suite

**Intent**: Verify all tests pass after the changes, including integration tests against real Spotlight.

**Work**:
- Run `swift test` to execute the full test suite
- Verify all tests pass (should be ~91 tests)
- Review any failures and fix them
- Confirm integration tests (SpotlightQueryTests) work correctly with the new syntax

**Done when**: `swift test` reports all tests passing with no failures or errors.

---

## S008: Manual Verification with Real Spotlight Query

**Intent**: Confirm the fix works with actual Spotlight searches, not just unit tests.

**Work**:
- Create a simple test script or use existing integration tests to execute a real text search query
- Test with a multi-word query (e.g., "architecture decisions") scoped to `.ushabti/docs`
- Verify results are returned (non-zero count)
- Test with both lowercase and mixed-case queries to confirm case-insensitivity works

**Done when**: Manual test confirms multi-word, case-insensitive text searches return expected results from real Spotlight index.

---

## S009: Build Release Binary

**Intent**: Verify the code compiles in release configuration and produces a working binary.

**Work**:
- Run `swift build -c release`
- Verify the build completes without errors
- Check that `.build/release/spotlight-mcp` exists

**Done when**: Release build completes successfully and binary exists.

---

## S010: Update Documentation

**Intent**: Reconcile `.ushabti/docs/search-module.md` to reflect the corrected implementation.

**Work**:
- Update line 196 in `.ushabti/docs/search-module.md` to describe the Spotlight-native syntax
- Change description from NSPredicate format to Spotlight query string format
- Document the key distinction: MDQuery uses Spotlight syntax, not NSPredicate syntax
- Update any examples that reference the text predicate construction

**Done when**: Documentation accurately describes the Spotlight-native `"*text*"cd` syntax and the reason for not using NSPredicate for text searches.

---

## S011: Correct kMDItemFSName to kMDItemTextContent

**Intent**: Use the correct Spotlight attribute for text content search as specified in the phase plan.

**Work**:
- Change line 29 of `Sources/SpotlightMCP/Search/QueryBuilder.swift` from `kMDItemFSName` to `kMDItemTextContent`
- Update all test expectations in `Tests/SpotlightMCPTests/Search/QueryBuilderTests.swift` to expect `kMDItemTextContent` in query strings (lines 11, 23, 24, 67)
- Re-run `swift test` to verify all tests pass with the corrected attribute
- Verify the change produces text content search behavior (searches file contents, not just filenames)

**Done when**: QueryBuilder.buildTextPredicate returns query string with `kMDItemTextContent == "*text*"cd`, all tests pass, and manual verification confirms text content search works correctly.

---

## S012: Correct Documentation to Reflect kMDItemTextContent

**Intent**: Update documentation to accurately describe text content search behavior using kMDItemTextContent.

**Work**:
- Update line 196 in `.ushabti/docs/search-module.md` to describe text content search (not filename search) using kMDItemTextContent
- Update design decision section (lines 304-310) to remove incorrect claims about kMDItemTextContent reliability
- Correct the implementation description to reference kMDItemTextContent
- Remove trade-offs section claiming limitation to filename matching

**Done when**: Documentation accurately describes kMDItemTextContent text content search behavior without incorrect claims about the attribute.
