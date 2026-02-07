# Phase 0005: Fix Case-Insensitive Text Search

## Intent

Fix critical bug in the `search` tool where multi-word text queries are case-sensitive, making the primary search functionality unreliable. The `QueryBuilder.buildTextPredicate` method currently uses `==` (case-sensitive matching) instead of `==[cd]` (case and diacritical insensitive matching), violating the spec requirement that text content searches use `kMDItemTextContent == *search term*cd`.

This phase corrects the predicate construction to match Spotlight's standard case-insensitive behavior and updates tests to verify the fix.

## Scope

### In Scope

- Fix `QueryBuilder.buildTextPredicate` to use `==[cd]` instead of `==`
- Update existing `naturalTextProducesTextContentPredicate` test to expect `==[cd]` in predicate format
- Add new unit test verifying case-insensitive predicate construction
- Verify all 90 existing tests still pass
- Rebuild release binary

### Out of Scope

- Changes to any other tool behavior
- Refactoring QueryBuilder beyond the single-line fix
- New features or enhancements
- Changes to search scope validation, pagination, or other search parameters
- Documentation updates (search-module.md already describes the intent correctly as "wildcard predicate for text search")

## Constraints

### Relevant Laws

- **L18 — Typed Throws**: Error handling must use typed throws (already compliant)
- **L20 — Public Method Test Coverage**: Every public method must have at least one test (adding test for case-insensitivity)
- **L22 — Test Idempotence**: Tests must be order-independent (will maintain)

### Relevant Style

- **Sandi Metz Rules**: Methods ≤5 lines, types ≤100 lines (already compliant, fix is one line)
- **Swift Idioms**: Immutability, functional patterns (already compliant)
- **Testing Strategy**: Every public method tested, descriptive test names (adding explicit case-insensitivity test)

## Acceptance Criteria

1. **Fix Applied**: `QueryBuilder.buildTextPredicate` uses `NSPredicate(format: "kMDItemTextContent ==[cd] %@", "*\(text)*" as NSString)`
2. **Existing Test Updated**: `naturalTextProducesTextContentPredicate` expects predicate format `kMDItemTextContent ==[cd] "*test*"`
3. **New Test Added**: New test explicitly verifies case-insensitive behavior (e.g., predicates for "hello world" and "HELLO WORLD" are functionally equivalent)
4. **All Tests Pass**: All 90 tests pass after changes
5. **Release Binary Built**: `swift build -c release` completes successfully

## Risks / Notes

**Known Impact**: This is a one-line fix in a well-isolated method. The change affects only text content matching behavior, making it correctly case-insensitive as originally intended by the spec.

**Test Coverage**: The existing test encoded the bug by expecting case-sensitive format. Updating it to expect `==[cd]` and adding an explicit case-insensitivity test ensures the fix is verified.

**No Breaking Changes**: This fix corrects broken behavior to match the documented spec. It makes searches more permissive (case-insensitive), not more restrictive, so it cannot break valid use cases.
