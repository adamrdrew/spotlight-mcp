# Phase 0002: Spotlight Query Engine

## Intent

Build a standalone Spotlight query layer that wraps macOS MDQuery and MDItem APIs, independent of MCP. This phase creates the core search abstraction that will be consumed by MCP tools in future phases. The goal is to provide a type-safe, tested interface to Spotlight that handles query construction, execution, result collection, and metadata extraction.

This phase isolates Spotlight integration complexity from MCP protocol concerns, enabling independent testing and evolution of the search layer.

## Scope

### In Scope

- SpotlightQuery wrapper around MDQuery (create, set scope, execute synchronously, collect results)
- MetadataItem wrapper around MDItem (get attribute, get all attributes, serialize to JSON-compatible types)
- QueryBuilder for predicate construction (natural text to predicate, raw predicate passthrough)
- KindMapping for UTI content type mapping (map user-friendly type names to UTI predicates)
- SearchResult and MetadataValue types for type-safe result representation
- Unit tests for predicate construction and type mapping
- Integration tests that query the real Spotlight index using controlled fixtures

### Out of Scope

- MCP tool integration (deferred to Phase 3)
- Asynchronous query execution (synchronous is acceptable for initial implementation)
- Query cancellation infrastructure
- Result caching or query optimization
- Pagination logic (will be added when integrated with MCP tools)
- Comprehensive logging (basic error logging is acceptable)
- Path sanitization and scope validation (will be added in security-focused phase)

## Constraints

### Laws

- **L01 (Swift 6 Language Level)**: All code must compile under Swift 6 strictness with typed concurrency.
- **L02 (No Private APIs)**: Only use public, documented CoreServices MDQuery/MDItem APIs.
- **L18 (Typed Throws)**: All throwing functions must use typed throws with specific error types.
- **L19 (Swift Testing Framework)**: Use Swift Testing for all tests.
- **L20 (Public Method Test Coverage)**: Every public method must have at least one test.
- **L22 (Test Idempotence)**: Tests must be order-independent and idempotent.
- **L23 (Integration Tests Use Fixtures)**: Integration tests must not depend on specific user data. Use controlled test fixtures or mock filesystem.
- **L24 (Mock Filesystem for Tests)**: Tests involving file I/O must use mock or in-memory filesystem.

### Style

- **Sandi Metz Rules**: Types ≤ 100 lines, methods ≤ 5 lines, parameters ≤ 4
- **Protocol-Oriented Programming**: Define protocols for search engine abstraction to enable testing
- **Value Semantics**: Prefer structs for SearchResult, MetadataValue, and query configuration types
- **Dependency Injection**: Pass collaborators via initializers
- **Functional Patterns**: Use map/filter/compactMap for collection transformations
- **Immutability**: Prefer let over var; immutable result types

## Acceptance Criteria

1. **SpotlightQuery Exists**: Type exists that can create an MDQuery, set search scope, execute synchronously, and return results
2. **MetadataItem Exists**: Type exists that can extract attributes from MDItem and serialize to JSON-compatible Swift types (String, Int, Double, Date, Array, Dictionary)
3. **QueryBuilder Exists**: Type exists that can construct NSPredicate from structured input (e.g., file type, date range) and pass through raw predicates
4. **KindMapping Exists**: Type exists that maps user-friendly kind names (e.g., "document", "image") to UTI-based predicates
5. **Types Defined**: SearchResult and MetadataValue types exist and are used by the query layer
6. **Unit Tests Pass**: Tests for QueryBuilder predicate construction and KindMapping pass
7. **Integration Tests Pass**: At least one integration test successfully queries the real Spotlight index and returns results (using fixtures or controlled test data)
8. **Full Test Coverage**: Every public method has at least one test
9. **Swift 6 Compilation**: All code compiles without errors or warnings under Swift 6 strictness
10. **No Dead Code**: All implemented code is referenced and used by tests or other components

## Risks / Notes

- **Synchronous Execution**: This phase uses synchronous MDQuery execution for simplicity. Asynchronous execution with progress updates will be added later if needed for MCP tool responsiveness.
- **No Pagination Yet**: Pagination logic is deferred to MCP tool integration. This phase focuses on raw query execution and result collection.
- **Fixture Dependency for Integration Tests**: Integration tests must use controlled fixtures (e.g., files created in /tmp) rather than user data. Test setup/teardown must create and clean up fixtures.
- **MDQuery API Verbosity**: MDQuery C-style APIs require careful memory and lifecycle management. Ensure query objects are retained during execution and results are collected before query lifecycle ends.
- **Metadata Attribute Names**: MDItem attribute names are string-based (e.g., kMDItemContentType). Consider defining constants or enums for commonly used attributes to avoid typos and improve type safety.
