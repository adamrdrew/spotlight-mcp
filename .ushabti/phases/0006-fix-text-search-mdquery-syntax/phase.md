# Phase 0006: Fix Text Search — Correct MDQuery Syntax

## Intent

Phase 0005 introduced a regression by changing `QueryBuilder.buildTextPredicate` to use `==[cd]` modifier syntax, which is valid NSPredicate syntax but **not** understood by MDQuery. This broke ALL text searches, including single-word queries that previously worked.

The root cause is that MDQuery uses Spotlight's native query string format, not NSPredicate's format. The `[cd]` modifier is an NSPredicate extension that MDQuery's parser does not recognize. Spotlight's native syntax for case-insensitive matching uses a `cd` suffix directly after the quoted string (e.g., `"*text*"cd`).

This phase corrects the approach by constructing Spotlight-native query strings directly, rather than using NSPredicate format strings that are incompatible with MDQuery.

## Scope

### In Scope

- Revert the Phase 0005 `==[cd]` change (it's a regression that broke all text searches)
- Fix `QueryBuilder.buildTextPredicate` to produce Spotlight-native case-insensitive query strings using the `"*text*"cd` suffix syntax
- Ensure the query string that reaches `MDQueryCreate` uses Spotlight query syntax, not NSPredicate syntax
- Update `QueryBuilderTests` to reflect the correct predicate format for Spotlight queries
- Add test verifying lowercase multi-word queries work correctly
- Verify all existing tests pass after the fix
- Rebuild the release binary

### Out of Scope

- Changes to other tool behavior beyond text search
- New features or enhancements
- Refactoring beyond what's needed for the MDQuery syntax fix
- Changes to metadata extraction, kind mapping, or date queries

## Constraints

### Relevant Laws

- **L18 — Typed Throws**: Error handling must use typed throws (already compliant)
- **L20 — Public Method Test Coverage**: Every public method must have at least one test (will maintain and improve)
- **L22 — Test Idempotence**: Tests must be order-independent (will maintain)
- **L29 — Documentation Reconciliation**: Documentation must be reconciled with code changes

### Relevant Style

- **Sandi Metz Rules**: Methods ≤5 lines, types ≤100 lines (will maintain)
- **Swift Idioms**: Immutability, functional patterns (will maintain)
- **Testing Strategy**: Comprehensive test coverage with descriptive names

## Acceptance Criteria

1. **Phase 0005 Reversion**: The `==[cd]` change in `QueryBuilder.buildTextPredicate` has been reverted
2. **Correct Syntax Applied**: `QueryBuilder.buildTextPredicate` produces Spotlight-native query strings with the format `kMDItemTextContent == "*<text>*"cd`
3. **Query String Flow Verified**: The query string passed to `MDQueryCreate` uses Spotlight syntax, not NSPredicate syntax
4. **Tests Updated**: `QueryBuilderTests.swift` updated to expect Spotlight-native format
5. **Multi-Word Test Added**: New test verifies lowercase multi-word queries produce working predicates
6. **All Tests Pass**: All tests pass after the fix (including integration tests against real Spotlight)
7. **Release Binary Built**: `swift build -c release` completes successfully

## Risks / Notes

**MDQuery vs NSPredicate Dialect Incompatibility**: The key insight is that MDQuery and NSPredicate use different predicate string formats. NSPredicate's `[cd]` modifiers and `CAST()` functions are not understood by MDQuery. Spotlight uses its own query string syntax where case/diacritical insensitivity is expressed as a suffix to the quoted string.

**Implementation Approach**: The fix requires bypassing NSPredicate for text searches. Instead of constructing an NSPredicate and extracting its `predicateFormat`, the code should build the Spotlight query string directly and pass it to `MDQueryCreate`. The `SpotlightQuery` initializer already accepts raw query strings via the `init(queryString:scope:)` path.

**Breaking vs Fixing**: This change **fixes** broken functionality introduced in Phase 0005. It restores working text search behavior that existed before Phase 0005 and makes it properly case-insensitive using the correct Spotlight syntax.
