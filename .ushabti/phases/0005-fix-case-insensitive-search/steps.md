# Implementation Steps

## S001: Fix QueryBuilder.buildTextPredicate to use case-insensitive matching

**Intent**: Correct the predicate format to use `==[cd]` instead of `==` for case and diacritical insensitive matching.

**Work**:
- Open `Sources/SpotlightMCP/Search/QueryBuilder.swift`
- Locate `buildTextPredicate` method (line 28-33)
- Change predicate format string from `"kMDItemTextContent == %@"` to `"kMDItemTextContent ==[cd] %@"`

**Done when**:
- `buildTextPredicate` method uses `NSPredicate(format: "kMDItemTextContent ==[cd] %@", "*\(text)*" as NSString)`

---

## S002: Update existing test to expect case-insensitive format

**Intent**: Update the test that verifies predicate format to expect the corrected `==[cd]` modifier.

**Work**:
- Open `Tests/SpotlightMCPTests/Search/QueryBuilderTests.swift`
- Locate `naturalTextProducesTextContentPredicate` test (line 8-14)
- Change expected predicate format from `"kMDItemTextContent == \"*test*\""` to `"kMDItemTextContent ==[cd] \"*test*\""`

**Done when**:
- Test expects `kMDItemTextContent ==[cd] "*test*"` format
- Test passes with updated QueryBuilder implementation

---

## S003: Add new test verifying case-insensitive behavior

**Intent**: Add explicit test confirming that predicates built from different-cased text are functionally equivalent.

**Work**:
- Add new test `caseInsensitiveTextMatching` to `QueryBuilderTests`
- Build predicates for both lowercase and uppercase versions of a multi-word phrase
- Verify both predicates produce format containing `==[cd]` modifier
- Verify predicate formats differ only in the search term casing, not in the comparison operator

**Done when**:
- New test `caseInsensitiveTextMatching` exists in `QueryBuilderTests.swift`
- Test builds predicates from "hello world" and "HELLO WORLD"
- Test verifies both contain `==[cd]` in their predicate format
- Test passes

---

## S004: Verify all existing tests pass

**Intent**: Ensure the fix doesn't break any existing functionality.

**Work**:
- Run `swift test` in the project root
- Verify all 90 tests pass
- Check that no new warnings or errors are introduced

**Done when**:
- `swift test` completes with all tests passing
- No new compiler warnings or errors
- Test output shows 90 passing tests

---

## S005: Build release binary

**Intent**: Verify the fix compiles cleanly in release configuration.

**Work**:
- Run `swift build -c release`
- Verify build completes successfully
- Confirm binary is produced at `.build/release/spotlight-mcp`

**Done when**:
- `swift build -c release` completes without errors
- Release binary exists at `.build/release/spotlight-mcp`

---

## F001: Update search-module.md to reflect case-insensitive matching

**Intent**: Reconcile documentation with the code change to satisfy L29 (Documentation Reconciliation in Every Phase).

**Work**:
- Open `.ushabti/docs/search-module.md`
- Locate line 196 in the QueryBuilder Methods section
- Change description from `Creates wildcard predicate for text search (kMDItemTextContent == "*text*")` to `Creates case-insensitive wildcard predicate for text search (kMDItemTextContent ==[cd] "*text*")`

**Done when**:
- Documentation accurately describes the `==[cd]` case-insensitive matching behavior
- The example accurately shows the predicate format with the `==[cd]` modifier
