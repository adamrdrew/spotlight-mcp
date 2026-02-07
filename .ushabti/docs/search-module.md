# Search Module Documentation

## Overview

The Search module provides a type-safe, tested abstraction layer over macOS Spotlight (MDQuery/MDItem APIs). It isolates Spotlight integration complexity from MCP protocol concerns, enabling independent testing and evolution of the search layer.

The module is located in `Sources/SpotlightMCP/Search/` and consists of six primary components: value types, query execution, predicate construction, content type mapping, and metadata extraction.

## Architecture

### Design Principles

1. **Protocol-Oriented Programming**: Types define clear interfaces for testing and composition
2. **Value Semantics**: All result types are immutable structs with value semantics
3. **Typed Errors**: All error-throwing functions use Swift 6 typed throws
4. **Synchronous Execution**: Queries execute synchronously for initial implementation simplicity
5. **Dependency Injection**: Collaborators are passed via initializers

### Module Boundaries

The Search module:
- **Owns**: Spotlight API interaction, query construction, metadata extraction, result serialization
- **Provides**: Type-safe query execution and JSON-compatible result representation
- **Does Not**: Handle MCP protocol concerns, implement pagination logic, manage async execution, perform path sanitization

## Public Types

### SearchResult

**Location**: `Sources/SpotlightMCP/Search/Types.swift`

**Purpose**: Represents a single search result from Spotlight.

**Definition**:
```swift
public struct SearchResult: Equatable, Codable, Sendable {
    public let path: URL
    public let metadata: [String: MetadataValue]
}
```

**Properties**:
- `path`: Absolute file path of the result
- `metadata`: Dictionary of metadata attributes extracted from MDItem

**Conformances**: Equatable, Codable, Sendable

**Usage**:
```swift
let result = SearchResult(
    path: URL(fileURLWithPath: "/Users/example/document.pdf"),
    metadata: ["kMDItemContentType": .string("com.adobe.pdf")]
)
```

### MetadataValue

**Location**: `Sources/SpotlightMCP/Search/Types.swift`

**Purpose**: Represents a metadata value that can be serialized to JSON.

**Definition**:
```swift
public enum MetadataValue: Equatable, Codable, Sendable {
    case string(String)
    case int(Int)
    case double(Double)
    case date(Date)
    case array([MetadataValue])
    case dictionary([String: MetadataValue])
}
```

**Cases**:
- `string(String)`: Text values
- `int(Int)`: Integer values
- `double(Double)`: Floating-point values
- `date(Date)`: Date/timestamp values
- `array([MetadataValue])`: Array of metadata values
- `dictionary([String: MetadataValue])`: Nested metadata dictionaries

**Conformances**: Equatable, Codable, Sendable

**Codable Implementation**: Uses `SingleValueContainer` for direct encoding/decoding to JSON primitives.

**Usage**:
```swift
let stringValue = MetadataValue.string("example.txt")
let intValue = MetadataValue.int(42)
let arrayValue = MetadataValue.array([.string("a"), .int(1)])
```

### SpotlightQuery

**Location**: `Sources/SpotlightMCP/Search/SpotlightQuery.swift`

**Purpose**: Wraps MDQuery for type-safe Spotlight query execution.

**Definition**:
```swift
public struct SpotlightQuery {
    public let predicate: NSPredicate
    public let scope: [URL]

    public init(predicate: NSPredicate, scope: [URL])
    public func execute() throws(QueryError) -> [SearchResult]
}
```

**Properties**:
- `predicate`: NSPredicate defining search criteria
- `scope`: Array of directory URLs to search within

**Methods**:
- `execute()`: Executes the query synchronously and returns results

**Errors**: Throws `QueryError` on execution failure or invalid scope.

**MDQuery Lifecycle**: Creates MDQuery, sets scope, executes synchronously, collects results, and converts MDItems to SearchResults. Query objects are retained during execution.

**Usage**:
```swift
let predicate = NSPredicate(format: "kMDItemTextContent CONTAINS[cd] %@", "search term")
let query = SpotlightQuery(
    predicate: predicate,
    scope: [URL(fileURLWithPath: "/Users/example/Documents")]
)
let results = try query.execute()
```

### MetadataItem

**Location**: `Sources/SpotlightMCP/Search/MetadataItem.swift`

**Purpose**: Wraps an MDItem for type-safe attribute extraction.

**Definition**:
```swift
public struct MetadataItem {
    public init(item: MDItem)
    public func getAttribute(_ key: String) -> MetadataValue?
    public func getAllAttributes() -> [String: MetadataValue]
}
```

**Methods**:
- `getAttribute(_ key:)`: Extracts a single attribute by key
- `getAllAttributes()`: Extracts all available attributes as a dictionary

**Type Conversion**: Converts MDItem attribute values to MetadataValue enum cases:
- `String` → `.string`
- `NSNumber` (int) → `.int`
- `NSNumber` (float/double) → `.double`
- `Date` → `.date`
- `[Any]` → `.array` (if all elements convertible)
- `[String: Any]` → `.dictionary` (if all values convertible)

**Usage**:
```swift
let item = MetadataItem(item: mdItem)
if let contentType = item.getAttribute("kMDItemContentType"),
   case .string(let type) = contentType {
    print("Content type: \(type)")
}
let allMetadata = item.getAllAttributes()
```

### QueryBuilder

**Location**: `Sources/SpotlightMCP/Search/QueryBuilder.swift`

**Purpose**: Provides safe, structured API for constructing NSPredicate from high-level search parameters.

**Definition**:
```swift
public struct QueryBuilder {
    public static func naturalText(_ text: String) -> NSPredicate
    public static func rawPredicate(_ predicateString: String) throws(BuilderError) -> NSPredicate
    public static func kind(_ kind: String) -> NSPredicate?
}
```

**Methods**:
- `naturalText(_ text:)`: Creates predicate for natural language text search (kMDItemTextContent contains text)
- `rawPredicate(_ predicateString:)`: Parses and validates raw predicate strings
- `kind(_ kind:)`: Delegates to KindMapping to create UTI-based predicate

**Errors**: Throws `BuilderError` for invalid predicate strings.

**Usage**:
```swift
let textPredicate = QueryBuilder.naturalText("important document")
let rawPredicate = try QueryBuilder.rawPredicate("kMDItemFSSize > 1000000")
let imagePredicate = QueryBuilder.kind("image")
```

### KindMapping

**Location**: `Sources/SpotlightMCP/Search/KindMapping.swift`

**Purpose**: Maps user-friendly kind names to UTI-based Spotlight predicates.

**Definition**:
```swift
public struct KindMapping {
    public static func predicate(forKind kind: String) -> NSPredicate?
}
```

**Methods**:
- `predicate(forKind:)`: Maps kind string to UTI predicate (case-insensitive)

**Supported Kinds**:
- `"document"` → kUTTypeText conformance
- `"image"` → kUTTypeImage conformance
- `"video"` → kUTTypeVideo conformance
- `"audio"` → kUTTypeAudio conformance
- `"pdf"` → kUTTypePDF conformance
- `"code"` → kUTTypeSourceCode conformance

**UTI Matching Strategy**: Uses `kMDItemContentTypeTree` for hierarchical UTI matching to catch all conforming types.

**Usage**:
```swift
if let imagePredicate = KindMapping.predicate(forKind: "image") {
    let query = SpotlightQuery(predicate: imagePredicate, scope: [url])
    let results = try query.execute()
}
```

## Error Types

### QueryError

**Location**: `Sources/SpotlightMCP/Search/SpotlightQuery.swift`

**Purpose**: Errors that can occur during query execution.

**Definition**:
```swift
public enum QueryError: Error, Equatable, Sendable {
    case executionFailed
    case invalidScope
}
```

**Cases**:
- `executionFailed`: MDQuery creation or execution failed
- `invalidScope`: Empty or invalid scope array provided

### MetadataError

**Location**: `Sources/SpotlightMCP/Search/MetadataItem.swift`

**Purpose**: Errors that can occur when working with metadata items.

**Definition**:
```swift
public enum MetadataError: Error, Equatable, Sendable {
    case invalidAttribute(String)
    case conversionFailed(String)
}
```

**Cases**:
- `invalidAttribute(String)`: Requested attribute does not exist
- `conversionFailed(String)`: Attribute value could not be converted to MetadataValue

**Note**: Current implementation returns nil instead of throwing. These error cases are defined for future use.

### BuilderError

**Location**: `Sources/SpotlightMCP/Search/QueryBuilder.swift`

**Purpose**: Errors that can occur during predicate construction.

**Definition**:
```swift
public enum BuilderError: Error, Equatable, Sendable {
    case invalidPredicate(String)
}
```

**Cases**:
- `invalidPredicate(String)`: Raw predicate string could not be parsed

## Design Decisions

### Synchronous Execution

**Decision**: Use synchronous MDQuery execution (`kMDQuerySynchronous`).

**Rationale**: Simplifies initial implementation. Asynchronous execution with progress updates can be added later if needed for MCP tool responsiveness.

**Trade-offs**: Queries may block briefly during execution. Acceptable for typical query complexity and result set sizes.

### MDQuery Lifecycle Management

**Decision**: Create MDQuery per execution, retain during execution, release after result collection.

**Rationale**: MDQuery results are valid only during query lifetime. Collecting results immediately ensures data validity.

**Implementation**: `SpotlightQuery.execute()` creates query, executes synchronously, collects results into `SearchResult` array, then allows query to be released.

### UTI Mapping Strategy

**Decision**: Use `kMDItemContentTypeTree` for kind mapping instead of exact `kMDItemContentType` matches.

**Rationale**: `ContentTypeTree` provides hierarchical matching. For example, searching for "image" will match JPEG, PNG, GIF, etc., without enumerating every image UTI.

**Example**: `KindMapping.predicate(forKind: "image")` produces predicate `kMDItemContentTypeTree == "public.image"`, matching all image subtypes.

### Metadata Attribute Constants

**Decision**: Use string literals for MDItem attribute names (e.g., `kMDItemPath as String`).

**Rationale**: CoreServices provides constants as `CFString`. Converting to Swift `String` at call sites avoids defining duplicate constants.

**Future Consideration**: If attribute names are used frequently across the codebase, consider defining typed enum or constants for commonly used attributes to improve type safety and reduce typos.

### Value Type Result Representation

**Decision**: Use immutable struct `SearchResult` with value semantics for results.

**Rationale**: Value types are thread-safe, easy to test, and align with Swift best practices. Immutability ensures results cannot be modified after creation.

**JSON Serialization**: `MetadataValue` enum provides JSON-compatible representation without depending on Foundation JSON serialization internals.

## Examples

### Basic Text Search

```swift
let predicate = QueryBuilder.naturalText("meeting notes")
let query = SpotlightQuery(
    predicate: predicate,
    scope: [URL(fileURLWithPath: "/Users/example/Documents")]
)
let results = try query.execute()

for result in results {
    print("Path: \(result.path)")
    if let contentType = result.metadata["kMDItemContentType"],
       case .string(let type) = contentType {
        print("Type: \(type)")
    }
}
```

### Search by File Kind

```swift
guard let predicate = QueryBuilder.kind("pdf") else {
    throw BuilderError.invalidPredicate("Unknown kind: pdf")
}

let query = SpotlightQuery(
    predicate: predicate,
    scope: [URL(fileURLWithPath: "/Users/example/Documents")]
)
let results = try query.execute()
print("Found \(results.count) PDF files")
```

### Raw Predicate with Custom Criteria

```swift
let predicate = try QueryBuilder.rawPredicate(
    "kMDItemFSSize > 1000000 && kMDItemContentModificationDate > $time"
)
let query = SpotlightQuery(
    predicate: predicate,
    scope: [URL(fileURLWithPath: "/Users/example/Downloads")]
)
let results = try query.execute()
```

### Extract Specific Metadata Attributes

```swift
let query = SpotlightQuery(predicate: predicate, scope: [url])
let results = try query.execute()

for result in results {
    if let createdDate = result.metadata["kMDItemFSCreationDate"],
       case .date(let date) = createdDate {
        print("Created: \(date)")
    }

    if let fileSize = result.metadata["kMDItemFSSize"],
       case .int(let size) = fileSize {
        print("Size: \(size) bytes")
    }
}
```

## Testing Strategy

### Unit Tests

**Location**: `Tests/SpotlightMCPTests/Search/`

**Coverage**:
- `QueryBuilderTests.swift`: Predicate construction logic
- `KindMappingTests.swift`: UTI predicate mapping
- `TypesTests.swift`: Codable conformance for MetadataValue

**Approach**: Test predicate construction and mapping without executing real Spotlight queries.

### Integration Tests

**Location**: `Tests/SpotlightMCPTests/Search/SpotlightQueryTests.swift`

**Coverage**:
- Query execution against real Spotlight index
- Result collection and metadata extraction
- Error handling (empty scope)

**Fixtures**: Tests use existing project files as controlled fixtures instead of creating temporary files, ensuring tests are reproducible and do not depend on Spotlight indexing latency.

**Idempotence**: All tests are order-independent and can run multiple times with consistent results.

## Future Enhancements

### Asynchronous Execution

Future phases may add asynchronous query execution with progress callbacks for long-running queries. This would require:
- MDQuery notification observers
- Progress callback API
- Cancellation support

### Query Combination

Future phases may add predicate combination logic (AND/OR/NOT) to QueryBuilder for complex queries:
```swift
let combined = QueryBuilder.combine([
    .naturalText("important"),
    .kind("document")
], using: .and)
```

### Result Pagination

Pagination logic is deferred to MCP tool integration. Future phases will add:
- Limit/offset parameters
- Cursor-based pagination
- Result streaming

### Metadata Attribute Typing

Future phases may add typed attribute accessors to avoid string-based attribute lookups:
```swift
extension SearchResult {
    var contentType: String? { ... }
    var creationDate: Date? { ... }
    var fileSize: Int? { ... }
}
```

### Path Sanitization Integration

Future phases will integrate path sanitization and scope validation to enforce security constraints (L05, L07).

## Related Documentation

- **Project Laws**: `.ushabti/laws.md` (L01, L02, L18-L24)
- **Style Guide**: `.ushabti/style.md` (Sandi Metz rules, value semantics, protocol-oriented programming)
- **Phase Plan**: `.ushabti/phases/0002-spotlight-query-engine/phase.md`
