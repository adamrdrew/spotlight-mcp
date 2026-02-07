# Steps for Phase 0002: Spotlight Query Engine

## S001: Create Types.swift with SearchResult and MetadataValue

**Intent**: Define the value types that represent search results and metadata values in a type-safe, JSON-serializable way.

**Work**:
- Create `Sources/SpotlightMCP/Search/Types.swift`
- Define `struct SearchResult` with path (URL) and metadata dictionary
- Define `enum MetadataValue` with cases for String, Int, Double, Date, Array, and Dictionary to represent JSON-compatible metadata types
- Add Equatable and Codable conformance to both types
- Ensure types are immutable (all stored properties are `let`)

**Done when**: Types.swift exists, defines SearchResult and MetadataValue with appropriate conformances, and compiles without errors.

---

## S002: Create MetadataItem.swift with MDItem wrapper

**Intent**: Provide a type-safe wrapper around MDItem for attribute extraction and serialization.

**Work**:
- Create `Sources/SpotlightMCP/Search/MetadataItem.swift`
- Define `struct MetadataItem` that wraps an MDItem reference
- Implement `getAttribute(_ key: String) -> MetadataValue?` to extract a single attribute
- Implement `getAllAttributes() -> [String: MetadataValue]` to extract all available attributes
- Handle type conversion from MDItem attribute values to MetadataValue cases
- Define `enum MetadataError: Error` for typed error handling (e.g., invalidAttribute, conversionFailed)

**Done when**: MetadataItem.swift exists, can extract attributes from MDItem, serializes to MetadataValue types, uses typed throws, and compiles without errors.

---

## S003: Create SpotlightQuery.swift with MDQuery wrapper

**Intent**: Provide a type-safe wrapper around MDQuery for query creation, scope setting, and synchronous execution.

**Work**:
- Create `Sources/SpotlightMCP/Search/SpotlightQuery.swift`
- Define `struct SpotlightQuery` with predicate and scope properties
- Implement `init(predicate: NSPredicate, scope: [URL])` initializer
- Implement `execute() throws(QueryError) -> [SearchResult]` that creates MDQuery, sets scope, executes synchronously, collects results, and converts MDItems to SearchResults
- Define `enum QueryError: Error` for typed error handling (e.g., executionFailed, invalidScope)
- Ensure MDQuery lifecycle is managed correctly (retain during execution)

**Done when**: SpotlightQuery.swift exists, can execute synchronous queries against Spotlight, returns SearchResult array, uses typed throws, and compiles without errors.

---

## S004: Create KindMapping.swift with UTI content type mapping

**Intent**: Map user-friendly kind names (e.g., "document", "image") to UTI-based Spotlight predicates.

**Work**:
- Create `Sources/SpotlightMCP/Search/KindMapping.swift`
- Define `struct KindMapping` with static methods or dictionary for common kind mappings
- Implement `predicate(forKind kind: String) -> NSPredicate?` that maps kind strings to UTI predicates (e.g., "image" -> kUTTypeImage)
- Define mappings for at least: document, image, video, audio, pdf, code
- Use kMDItemContentType or kMDItemContentTypeTree for UTI matching

**Done when**: KindMapping.swift exists, maps common kind names to UTI predicates, and compiles without errors.

---

## S005: Create QueryBuilder.swift with predicate construction

**Intent**: Provide a safe, structured API for constructing NSPredicate from high-level search parameters.

**Work**:
- Create `Sources/SpotlightMCP/Search/QueryBuilder.swift`
- Define `struct QueryBuilder` with methods for predicate construction
- Implement `naturalText(_ text: String) -> NSPredicate` that creates a predicate for natural language search (e.g., kMDItemTextContent contains text)
- Implement `rawPredicate(_ predicateString: String) throws(BuilderError) -> NSPredicate` that parses and validates raw predicate strings
- Implement `kind(_ kind: String) -> NSPredicate?` that delegates to KindMapping
- Define `enum BuilderError: Error` for typed error handling (e.g., invalidPredicate)
- Consider combining predicates with AND/OR logic in future (not required for this step)

**Done when**: QueryBuilder.swift exists, can construct predicates from structured input and raw strings, uses typed throws, and compiles without errors.

---

## S006: Write unit tests for QueryBuilder and KindMapping

**Intent**: Verify that predicate construction logic works correctly without executing real Spotlight queries.

**Work**:
- Create `Tests/SpotlightMCPTests/Search/QueryBuilderTests.swift`
- Write tests verifying QueryBuilder.naturalText() produces expected predicate format
- Write tests verifying QueryBuilder.rawPredicate() parses valid predicates and throws on invalid input
- Create `Tests/SpotlightMCPTests/Search/KindMappingTests.swift`
- Write tests verifying KindMapping.predicate(forKind:) returns correct UTI predicates for known kinds
- Write tests verifying unknown kinds return nil or appropriate error
- Use Swift Testing framework assertions

**Done when**: Unit test files exist, all tests pass, QueryBuilder and KindMapping predicate logic is verified without Spotlight execution.

---

## S007: Write integration tests for Spotlight query execution

**Intent**: Verify that the query layer can successfully execute real Spotlight queries and return results.

**Work**:
- Create `Tests/SpotlightMCPTests/Search/SpotlightQueryTests.swift`
- Set up test fixtures: create temporary files in /tmp with known metadata (e.g., text file with specific content)
- Write test that creates a SpotlightQuery scoped to /tmp, executes a query for the fixture file, and verifies results contain expected metadata
- Write test that verifies MetadataItem correctly extracts attributes from returned MDItems
- Ensure tests clean up fixtures in teardown
- Verify tests are idempotent and do not depend on user-specific data
- Handle case where Spotlight may not have indexed /tmp immediately (may require retry logic or explicit indexing trigger if possible)

**Done when**: Integration test file exists, tests pass, and successfully query real Spotlight index using controlled fixtures. Tests clean up after themselves and are idempotent.

---

## S008: Add tests for MetadataValue Codable conformance

**Intent**: Ensure public Codable methods have test coverage as required by L20.

**Work**:
- Create `Tests/SpotlightMCPTests/Search/TypesTests.swift`
- Write test verifying `MetadataValue.encode(to:)` correctly encodes all cases (string, int, double, date, array, dictionary)
- Write test verifying `MetadataValue.init(from:)` correctly decodes all cases
- Write test verifying round-trip encoding/decoding preserves values
- Write test verifying decode throws appropriate error for invalid data
- Use Swift Testing framework assertions

**Done when**: TypesTests.swift exists, all Codable methods have test coverage, and all tests pass.

---

## S009: Refactor methods to comply with 5-line limit

**Intent**: Bring all methods into compliance with Sandi Metz 5-line rule.

**Work**:
- Refactor `MetadataValue.init(from:)` by extracting decode logic into separate helper methods (one per type case)
- Refactor `MetadataValue.encode(to:)` by extracting encode logic into separate helper methods if needed
- Refactor `MetadataItem.extractAllAttributes()` by extracting the reduce operation into a helper method
- Refactor `MetadataItem.convertValue()` by extracting case handling into smaller methods
- Refactor `SpotlightQuery.performQuery()` by further breaking down query creation, execution, and result collection steps
- Verify all refactored code still compiles and all tests still pass

**Done when**: All methods are ≤5 lines (excluding blank lines and comments), code compiles without errors, and all existing tests pass.

---

## S010: Document Search module in .ushabti/docs

**Intent**: Reconcile documentation with implemented Search module to satisfy L29 and L32.

**Work**:
- Create `.ushabti/docs/search-module.md` documenting the Search module architecture
- Document all public types: SearchResult, MetadataValue, SpotlightQuery, MetadataItem, QueryBuilder, KindMapping
- Document error types: QueryError, MetadataError, BuilderError
- Include examples of query construction and execution
- Document design decisions (synchronous execution, MDQuery lifecycle, UTI mapping strategy)
- Update `.ushabti/docs/index.md` to link to search-module.md in table of contents
- Ensure documentation accurately reflects current implementation

**Done when**: Search module is fully documented in `.ushabti/docs/`, documentation accurately reflects implementation, and index.md links to new documentation.
