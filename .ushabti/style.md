# Project Style Guide

## Purpose

This style guide defines the conventions, patterns, and architectural expectations for Spotlight MCP development. These guidelines promote consistency, maintainability, and code quality across the codebase. All contributors must follow these conventions unless explicitly justified otherwise.

Reviewers should verify adherence to this style guide before approving changes. Style violations should be identified and corrected during review.

---

## Project Structure

### Directory Layout

```
spotlight-mcp/
├── Sources/
│   ├── SpotlightMCP/         # Main server implementation
│   │   ├── Server/           # MCP server infrastructure
│   │   ├── Tools/            # MCP tool implementations
│   │   ├── Search/           # Spotlight search abstraction
│   │   ├── Security/         # Path sanitization, TCC handling
│   │   └── Models/           # Data models and types
│   └── SpotlightMCPCore/     # Reusable core components
├── Tests/
│   ├── SpotlightMCPTests/    # Main test suite
│   └── Fixtures/             # Test fixtures and mock data
├── Package.swift
├── README.md
├── CHANGELOG.md
└── .ushabti/                 # Ushabti framework files
```

### Module Boundaries

- **SpotlightMCP**: Main executable module, MCP server implementation, tool definitions
- **SpotlightMCPCore**: Reusable abstractions for Spotlight search, security, and utilities (if needed for test isolation or future reuse)

### File Organization

- **One type per file** (exception: small, tightly-coupled private types < 20 lines)
- **File name matches primary type name**: `SearchQuery.swift` contains `struct SearchQuery`
- **Group related files by feature/domain**: All search-related types in `Search/`, all MCP tools in `Tools/`

### Ownership Expectations

- Each module has a clear responsibility boundary
- Cross-module dependencies must go through well-defined protocols
- No circular dependencies between modules

---

## Language & Tooling Conventions

### Language Version

- **Swift 6** language mode (enforced by L01)
- Leverage Swift 6 features: typed throws, strict concurrency checking, memory safety guarantees

### Build Tools

- **Swift Package Manager** for dependency management and build
- **Swift Testing** framework for all tests (enforced by L19)

### Dependency Management

- Prefer system frameworks over third-party dependencies
- All dependencies must be justified and documented in README
- Avoid transitive dependency bloat

---

## Sandi Metz's Rules (Enforced)

These rules enforce small, focused, composable design. They are strict conventions for this project.

### 1. Classes/Structs: Maximum 100 Lines of Code

- Excludes blank lines and comments
- If a type exceeds 100 lines, extract responsibilities into new types
- Favor composition over large, monolithic types

### 2. Methods: Maximum 5 Lines of Code

- Excludes blank lines and comments
- Forces single responsibility and clear naming
- Compose small methods into larger behaviors
- **Rationale**: Enforces clarity and testability. Methods that are too long are doing too much.

### 3. Methods: Maximum 4 Parameters

- If you need more than 4 parameters, create a parameter object (struct)
- Consider builder patterns for complex configuration
- **Example**: Prefer `func search(query: SearchQuery)` over `func search(terms: [String], scope: URL, limit: Int, offset: Int, timeout: TimeInterval)`

### 4. Top-Level Objects: Instantiate Only One Object

- Pass collaborators as dependencies via initializers
- Enforces loose coupling and testability
- **Example**: A server initializer should not create its own query engine, path sanitizer, and logger — these should be injected

### 5. Reminder: 100-Line Limit (Reinforced)

- This is a hard boundary. If you hit 100 lines, refactor immediately.

---

## Swift Idioms

### Prefer Immutability

- **Use `let` over `var` by default**
- Prefer value types (`struct`, `enum`) over reference types (`class`) when appropriate
- Immutable collections unless mutation is required: `let items: [Item]` over `var items: [Item]`

### Functional Patterns

- **Prefer `map`, `filter`, `reduce`, `compactMap` over imperative loops**
  ```swift
  // Good
  let validPaths = paths.compactMap { sanitize($0) }

  // Avoid
  var validPaths: [URL] = []
  for path in paths {
      if let sanitized = sanitize(path) {
          validPaths.append(sanitized)
      }
  }
  ```
- Use higher-order functions for collection transformations
- **Avoid side effects in pure functions** — mark side-effecting functions clearly:
  ```swift
  // Pure function
  func sanitize(_ path: String) -> URL? { ... }

  // Side-effecting function (document clearly)
  func openFile(at path: URL) throws { ... }  // Opens file (side effect)
  ```

### Error Handling

- **Use typed `throws` (Swift 6)** (enforced by L18)
  ```swift
  func search(query: SearchQuery) throws(SearchError) -> [SearchResult]
  ```
- **Never use `try!` or force-unwrapping in production code**
- Provide descriptive error types that aid debugging:
  ```swift
  enum SearchError: Error {
      case invalidScope(URL)
      case timeoutExceeded(TimeInterval)
      case tccDenied(URL)
  }
  ```

### Optionals

- Use optional chaining and nil coalescing operators
- **Avoid force-unwrapping** — prefer `guard` statements or `if let`:
  ```swift
  // Good
  guard let result = search(query: query) else { return }

  // Avoid
  let result = search(query: query)!
  ```
- Make optionality explicit in types: `var cachedResults: [SearchResult]?` clearly indicates optional state

### Naming

- **Clarity over brevity**
- Methods should read like sentences:
  ```swift
  query.search(for: term, in: scope)
  path.sanitize(within: allowedDirectory)
  ```
- **Avoid abbreviations** unless universally understood (`URL`, `ID`, `JSON` are acceptable)
- **Boolean properties should read as assertions**:
  ```swift
  isValid
  hasResults
  canExecute
  shouldPaginate
  ```

---

## Code Organization

### Type Organization (Within a File)

Organize type definitions in this order:

1. **Type declaration and stored properties**
2. **Initialization**
3. **Public interface** (public methods)
4. **Internal/private implementation** (private methods)
5. **Extensions for protocol conformance** (each protocol in its own extension)

**Example:**
```swift
struct SearchQuery {
    // 1. Properties
    let terms: [String]
    let scope: URL
    let limit: Int

    // 2. Initialization
    init(terms: [String], scope: URL, limit: Int = 100) {
        self.terms = terms
        self.scope = scope
        self.limit = limit
    }

    // 3. Public interface
    func execute() throws(SearchError) -> [SearchResult] {
        validate()
        return performSearch()
    }

    // 4. Private implementation
    private func validate() throws(SearchError) { ... }
    private func performSearch() -> [SearchResult] { ... }
}

// 5. Protocol conformance
extension SearchQuery: Equatable {}
extension SearchQuery: Codable {}
```

### Dependency Management

- **Dependencies injected via initializers**
- **No singletons** except for true application-wide state (logging, configuration)
- **Protocols for abstraction boundaries**:
  ```swift
  protocol PathSanitizer {
      func sanitize(_ path: String, within scope: URL) throws -> URL
  }

  struct DefaultPathSanitizer: PathSanitizer { ... }
  ```
- **Prefer composition over inheritance**

---

## Architectural Patterns

### Patterns to Embrace

#### Protocol-Oriented Programming

Define behavior through protocols. Use protocols to create abstraction boundaries and enable testability.

```swift
protocol SearchEngine {
    func search(query: SearchQuery) throws(SearchError) -> [SearchResult]
}

struct SpotlightSearchEngine: SearchEngine { ... }
struct MockSearchEngine: SearchEngine { ... }  // For tests
```

#### Value Semantics

Prefer structs and enums for data models. Value types provide safety, immutability by default, and eliminate reference-sharing bugs.

```swift
struct SearchResult {
    let path: URL
    let modifiedDate: Date
    let fileType: String
}
```

#### Result Builders

For DSL-like APIs where appropriate (e.g., query construction, configuration):

```swift
@resultBuilder
struct QueryBuilder {
    static func buildBlock(_ components: QueryComponent...) -> SearchQuery {
        SearchQuery(components: components)
    }
}
```

#### Actor Isolation

For thread-safe state management (enforced by L17). Use actors to protect mutable shared state.

```swift
actor QueryCache {
    private var cache: [SearchQuery: [SearchResult]] = [:]

    func get(_ query: SearchQuery) -> [SearchResult]? {
        cache[query]
    }

    func set(_ query: SearchQuery, results: [SearchResult]) {
        cache[query] = results
    }
}
```

### Patterns to Avoid

- **Massive view controllers / server objects**: Break up into smaller, focused types
- **Inheritance hierarchies**: Prefer protocol composition and value types
- **Mutable shared state without actors**: Use actors or eliminate mutability
- **Stringly-typed APIs**: Use enums and strong types instead of string constants

---

## Testing Strategy

### What Must Be Tested

- **Every public method** (enforced by L20)
- **Error paths and edge cases**
- **Security-sensitive code** (path sanitization, scope validation, TCC handling)
- **Integration points** (MCP protocol, Spotlight API)

### Test Location

- Tests live in `Tests/SpotlightMCPTests/`
- Test files mirror source structure: `Sources/SpotlightMCP/Search/SearchQuery.swift` → `Tests/SpotlightMCPTests/Search/SearchQueryTests.swift`
- Fixtures and mock data in `Tests/Fixtures/`

### Test Principles

- **Idempotent and order-independent** (enforced by L22)
- **Use fixtures, never user data** (enforced by L23)
- **Mock filesystem for I/O tests** (enforced by L24)
- **Descriptive test names**: `testSearchRespectsExplicitScope()`, not `testSearch1()`

### Acceptable Testing Tradeoffs

- **Unit tests over integration tests** where practical (faster, more isolated)
- **Mock external dependencies** (Spotlight, filesystem) to ensure test reliability
- **Prefer property-based tests** for logic with many edge cases (if applicable)

### Test Organization

```swift
import Testing
@testable import SpotlightMCP

@Suite("SearchQuery Tests")
struct SearchQueryTests {

    @Test("Search respects explicit scope")
    func searchRespectsExplicitScope() throws {
        let query = SearchQuery(terms: ["test"], scope: URL(fileURLWithPath: "/tmp"))
        let results = try query.execute()
        #expect(results.allSatisfy { $0.path.path.starts(with: "/tmp") })
    }

    @Test("Search throws on invalid scope")
    func searchThrowsOnInvalidScope() {
        #expect(throws: SearchError.invalidScope) {
            let query = SearchQuery(terms: ["test"], scope: URL(fileURLWithPath: "../invalid"))
            try query.execute()
        }
    }
}
```

---

## Error Handling & Observability

### Logging

- Use structured logging (e.g., `Logger` from `os.log`)
- **Minimal result logging** (enforced by L08) — do not log search results in production
- Log levels:
  - **Error**: Failures requiring attention
  - **Warning**: Recoverable issues (e.g., TCC denial)
  - **Info**: High-level operational events (server start, tool invocation)
  - **Debug**: Detailed diagnostic information (disabled in release builds)

### Error Propagation

- Throw errors upward with typed throws
- Handle errors at appropriate boundaries (MCP tool layer converts errors to JSON responses)
- Provide context in error messages:
  ```swift
  throw SearchError.invalidScope(scope)  // Good: includes problematic scope
  throw SearchError.invalidScope()       // Bad: no context
  ```

### Metrics / Tracing

- If performance monitoring is needed in the future, instrument at tool boundaries
- Measure query latency, result set sizes, timeout occurrences
- Not required for initial implementation

---

## Performance & Resource Use

### Expectations

- Queries should complete within documented timeout (enforced by L14)
- Result sets capped at documented limits (enforced by L10, L15)
- Memory usage proportional to result set size (no unbounded allocations)

### Common Pitfalls

- **Unbounded searches**: Always enforce scope, pagination, and timeouts
- **Main thread blocking**: Use async/await for I/O operations (enforced by L16)
- **Excessive logging**: Avoid logging large result sets or sensitive data (enforced by L08)
- **Retaining large result sets**: Return results and release references promptly

---

## Review Checklist

Before approving any change, reviewers must verify:

### Code Quality

- [ ] All types ≤ 100 lines (Sandi Metz rule)
- [ ] All methods ≤ 5 lines (Sandi Metz rule)
- [ ] All methods ≤ 4 parameters (Sandi Metz rule)
- [ ] Dependencies injected, not instantiated (Sandi Metz rule)
- [ ] No dead code (enforced by L21)
- [ ] `let` preferred over `var` where possible
- [ ] No force-unwrapping (`!`) in production code

### Error Handling

- [ ] Typed throws used for all error-throwing functions (enforced by L18)
- [ ] Descriptive error types with context
- [ ] No `try!` in production code

### Security & Privacy

- [ ] File paths sanitized (enforced by L07)
- [ ] Search scope explicit and validated (enforced by L05)
- [ ] TCC boundaries respected (enforced by L06)
- [ ] No sensitive data logged (enforced by L08)

### Testing

- [ ] Every public method has at least one test (enforced by L20)
- [ ] Tests are idempotent and order-independent (enforced by L22)
- [ ] Tests use fixtures, not user data (enforced by L23)
- [ ] Tests use mock filesystem (enforced by L24)

### Documentation

- [ ] Public APIs documented with clear descriptions
- [ ] README updated if tools or configuration changed (enforced by L28)
- [ ] `.ushabti/docs` reconciled with code changes (enforced by L29)

### Protocol Compliance

- [ ] MCP tools return structured JSON (enforced by L09)
- [ ] Pagination implemented for operations returning >100 results (enforced by L10)
- [ ] Timeouts enforced on searches (enforced by L14)
- [ ] Result set limits documented and enforced (enforced by L15)
- [ ] Absolute file paths in responses (enforced by L12)
- [ ] ISO 8601 for datetime values (enforced by L11)
- [ ] Read-only vs. side-effect separation clear (enforced by L13)

### Concurrency

- [ ] No blocking operations on main thread (enforced by L16)
- [ ] Actors used for shared mutable state (enforced by L17)

---

## Writing Rules

When writing code or reviewing changes, follow these principles:

1. **Be explicit and actionable**: Prefer concrete guidance over abstract principles
2. **Prefer examples over abstractions**: Show what good code looks like
3. **Avoid "should" unless flexibility is intentional**: Use "must" for requirements
4. **Avoid vague guidance**: Replace "clean," "simple," "nice" with specific expectations
5. **Keep code concise but complete**: Favor small, focused types and methods

---

## Summary

This style guide establishes conventions for building Spotlight MCP with clarity, consistency, and maintainability. By following Sandi Metz's rules, Swift idioms, and the patterns outlined here, we ensure a codebase that is easy to understand, test, and evolve.

All style guidance must be compatible with the laws defined in `.ushabti/laws.md`. If a conflict arises, laws take precedence.
