# Project Laws

## Preamble

These laws define the non-negotiable invariants for Spotlight MCP, an MCP server that exposes macOS Spotlight functionality to LLMs. Every implementation, refactor, and phase must satisfy these constraints. Reviewers must verify compliance before marking any phase complete.

## Laws

### L01 — Swift 6 Language Level
- **Rule:** The project MUST use Swift 6 language mode.
- **Rationale:** Swift 6 provides memory safety guarantees, modern concurrency features, and typed throws that are foundational to the project's safety and correctness goals.
- **Enforcement:** Build settings and Package.swift must specify Swift 6. Compilation must succeed under Swift 6 strictness.
- **Scope:** All Swift code in the project.
- **Exceptions:** None.

### L02 — No Private APIs
- **Rule:** The project MUST NOT use any private Apple APIs. Only public, documented system frameworks are permitted.
- **Rationale:** Private APIs violate App Store guidelines, may break across OS updates, and undermine long-term maintainability and trustworthiness.
- **Enforcement:** Code review must verify all framework imports and API calls reference publicly documented APIs. No use of runtime introspection to access undocumented symbols.
- **Scope:** All framework usage.
- **Exceptions:** None.

### L03 — No Escalated Privileges
- **Rule:** The server MUST NOT require root privileges, entitlements beyond standard user access, or elevated permissions.
- **Rationale:** Requiring elevated privileges violates the principle of least privilege, introduces security risk, and complicates deployment.
- **Enforcement:** Verify that the binary runs as a standard user process without special entitlements. Check Info.plist and entitlements files.
- **Scope:** All deployment configurations.
- **Exceptions:** None.

### L04 — No Raw Query Construction Exposure
- **Rule:** The project MUST NOT expose raw NSQuery, NSPredicate construction, or low-level Spotlight API primitives to MCP consumers.
- **Rationale:** Raw query construction allows unsafe, unpredictable, or performance-degrading queries. The server must provide safe, opinionated abstractions.
- **Enforcement:** MCP tool definitions must accept only high-level, structured parameters (e.g., file types, date ranges). No predicate strings accepted from clients.
- **Scope:** All MCP tool interfaces.
- **Exceptions:** None.

### L05 — Explicit Search Scope Required
- **Rule:** All search operations MUST require an explicit scope (target directories or user-approved defaults). System-wide searches without scope are forbidden.
- **Rationale:** System-wide searches risk exposing sensitive data, violate user privacy expectations, and can cause performance issues.
- **Enforcement:** All search functions must accept a scope parameter. If a default scope exists, it must be documented and user-configurable. Reviewer must verify no code paths allow unbounded searches.
- **Scope:** All search operations.
- **Exceptions:** None.

### L06 — TCC Boundary Respect
- **Rule:** The server MUST respect macOS Transparency, Consent, and Control (TCC) boundaries. If Spotlight cannot access a resource due to TCC restrictions, the server MUST NOT attempt to access it.
- **Rationale:** TCC is a core macOS security mechanism. Violating TCC undermines user trust and system security.
- **Enforcement:** Do not attempt workarounds for TCC-restricted paths. Handle TCC denials gracefully with clear error messages.
- **Scope:** All file and resource access.
- **Exceptions:** None.

### L07 — File Path Sanitization
- **Rule:** All file paths received as input MUST be sanitized to prevent directory traversal attacks (e.g., `../`, symbolic link exploitation).
- **Rationale:** Unsanitized paths can allow attackers to access files outside intended scope.
- **Enforcement:** Use Foundation's URL standardization and real path resolution. Verify resolved paths remain within allowed scope before access. Code review must confirm sanitization on all path inputs.
- **Scope:** All scope parameters and file path inputs.
- **Exceptions:** None.

### L08 — Minimal Result Logging
- **Rule:** The server MUST NOT capture, persist, or log search results beyond what the MCP protocol requires for operation.
- **Rationale:** Search results may contain sensitive user data. Excessive logging violates privacy principles and increases risk of data exposure.
- **Enforcement:** Audit logging code to ensure search results are not written to files, persistent stores, or transmitted outside the MCP protocol. Transient logging for debugging must be clearly marked and disabled in release builds.
- **Scope:** All logging and data persistence.
- **Exceptions:** None.

### L09 — Structured JSON Responses
- **Rule:** All MCP tools MUST return structured JSON. No tools may return raw strings that require parsing by the client.
- **Rationale:** Structured responses are type-safe, predictable, and prevent client-side parsing errors.
- **Enforcement:** MCP tool definitions must specify JSON schemas. Code review must verify all tool responses conform to declared schemas.
- **Scope:** All MCP tool responses.
- **Exceptions:** None.

### L10 — Mandatory Pagination
- **Rule:** Any operation that could return more than 100 results MUST implement pagination.
- **Rationale:** Unbounded result sets can cause memory issues, timeouts, and poor UX.
- **Enforcement:** All search operations must accept limit/offset or cursor-based pagination parameters. Default limits must be documented. Reviewer must verify no code path returns unbounded results.
- **Scope:** All search and listing operations.
- **Exceptions:** None.

### L11 — ISO 8601 DateTime Format
- **Rule:** All time-based queries and datetime values in responses MUST use ISO 8601 format.
- **Rationale:** ISO 8601 is unambiguous, widely supported, and timezone-aware.
- **Enforcement:** Code review must verify all datetime serialization/deserialization uses ISO 8601. Reject proprietary or locale-dependent formats.
- **Scope:** All datetime handling.
- **Exceptions:** None.

### L12 — Absolute File Paths Only
- **Rule:** All file paths in MCP responses MUST be absolute. Relative paths are forbidden.
- **Rationale:** Relative paths are ambiguous and client-environment dependent. Absolute paths are unambiguous.
- **Enforcement:** Verify all file path construction uses absolute path methods. Code review must flag any relative path returns.
- **Scope:** All file path outputs.
- **Exceptions:** None.

### L13 — Read-Only vs. Side-Effect Separation
- **Rule:** MCP tools MUST clearly separate read-only operations from those that trigger side effects (e.g., opening files, launching applications).
- **Rationale:** Clients must be able to reason about safety of operations. Unexpected side effects undermine predictability and safety.
- **Enforcement:** Tool naming and descriptions must clearly indicate side effects. Code review must verify read-only tools truly have no side effects. Side-effect tools must document behavior.
- **Scope:** All MCP tool definitions and implementations.
- **Exceptions:** None.

### L14 — Query Timeout Enforcement
- **Rule:** All search operations MUST enforce timeouts. No unbounded searches are permitted.
- **Rationale:** Unbounded searches can hang indefinitely, degrading server responsiveness and user experience.
- **Enforcement:** All query operations must specify timeout parameters. Default timeouts must be documented. Reviewer must verify timeout handling in all search code paths.
- **Scope:** All search operations.
- **Exceptions:** None.

### L15 — Result Set Limits Documented and Enforced
- **Rule:** Every function that returns results MUST document and enforce maximum result set sizes.
- **Rationale:** Unbounded result sets risk memory exhaustion and performance degradation.
- **Enforcement:** Function documentation must specify maximum result counts. Code must enforce these limits. Reviewer must verify limits are honored.
- **Scope:** All functions returning collections.
- **Exceptions:** None.

### L16 — No Main Thread Blocking
- **Rule:** If async operations exist, no blocking operations may run on the main thread.
- **Rationale:** Blocking the main thread degrades responsiveness and violates Swift concurrency best practices.
- **Enforcement:** Use async/await for I/O and long-running operations. Code review must flag blocking calls on main thread where async alternatives exist.
- **Scope:** All threading and concurrency.
- **Exceptions:** None.

### L17 — Actor-Based State Management
- **Rule:** If threading is required, state management MUST use Swift actors for thread safety.
- **Rationale:** Actors provide compile-time guarantees against data races, which manual locking cannot.
- **Enforcement:** Code review must verify all shared mutable state is protected by actors. No manual locks unless actors are provably insufficient.
- **Scope:** All concurrent state access.
- **Exceptions:** None.

### L18 — Typed Throws
- **Rule:** All error-throwing functions MUST use typed throws (Swift 6 typed error handling).
- **Rationale:** Typed throws provide compile-time error handling guarantees and improve API clarity.
- **Enforcement:** Code review must verify all throwing functions specify error types. Reject untyped `throws`.
- **Scope:** All error handling.
- **Exceptions:** None.

### L19 — Swift Testing Framework
- **Rule:** The project MUST use Swift Testing as its testing framework.
- **Rationale:** Swift Testing is the modern, first-party testing framework for Swift 6, providing better integration and features than XCTest.
- **Enforcement:** Package.swift and test code must use Swift Testing. No XCTest dependencies permitted.
- **Scope:** All test code.
- **Exceptions:** None.

### L20 — Public Method Test Coverage
- **Rule:** Every public method MUST have at least one test.
- **Rationale:** Public methods define the API contract. Untested public methods risk regressions and unverified behavior.
- **Enforcement:** Code review must verify test coverage for all public methods. Coverage reports must confirm this.
- **Scope:** All public methods.
- **Exceptions:** None.

### L21 — No Dead Code
- **Rule:** No code may exist that is not referenced or consumed by something else in the codebase.
- **Rationale:** Dead code increases maintenance burden, confuses readers, and hides intent.
- **Enforcement:** Code review must identify unreferenced functions, types, and variables. Use static analysis to detect dead code. Reject PRs introducing dead code.
- **Scope:** All code.
- **Exceptions:** None.

### L22 — Test Idempotence and Independence
- **Rule:** All tests MUST be idempotent and order-independent. Running tests in any order or multiple times must produce identical results.
- **Rationale:** Order-dependent tests are fragile, hard to debug, and undermine test reliability.
- **Enforcement:** Tests must not share mutable state. Each test must set up and tear down its own fixtures. Reviewer must verify no global state pollution.
- **Scope:** All tests.
- **Exceptions:** None.

### L23 — Integration Tests Use Fixtures
- **Rule:** Integration tests MUST NOT depend on specific user data. All integration tests must use fixtures or mocked data.
- **Rationale:** Tests depending on user data are non-portable, unreliable, and violate privacy.
- **Enforcement:** Code review must verify integration tests use controlled test data. No references to paths like ~/Documents or user-specific files.
- **Scope:** All integration tests.
- **Exceptions:** None.

### L24 — Mock Filesystem for Tests
- **Rule:** Tests MUST use a mock or in-memory filesystem. No tests may touch real user directories.
- **Rationale:** Tests touching real filesystems risk data loss, are non-portable, and violate isolation.
- **Enforcement:** Verify tests use mock filesystem implementations. Reject tests reading/writing to real user paths.
- **Scope:** All tests involving file I/O.
- **Exceptions:** None.

### L25 — Single Binary Output
- **Rule:** The build output MUST be a single binary with no runtime dependencies beyond macOS system frameworks.
- **Rationale:** Single binary deployment simplifies distribution, installation, and reduces dependency conflicts.
- **Enforcement:** Build configuration must produce one executable. No requirement for separate dylibs, resource bundles, or external dependencies at runtime.
- **Scope:** All build configurations.
- **Exceptions:** None.

### L26 — Semantic Versioning
- **Rule:** The project MUST follow semantic versioning (semver) for all releases.
- **Rationale:** Semver provides clear expectations about API compatibility and breaking changes.
- **Enforcement:** Version numbers must follow MAJOR.MINOR.PATCH. Code review must verify version bumps match change type (breaking, feature, fix).
- **Scope:** All releases.
- **Exceptions:** None.

### L27 — CHANGELOG Maintenance
- **Rule:** CHANGELOG.md MUST be updated for every release, documenting all user-facing changes.
- **Rationale:** A changelog provides users and maintainers with a clear history of changes.
- **Enforcement:** Release process must verify CHANGELOG.md is updated. Reviewer must confirm changelog entries match release scope.
- **Scope:** All releases.
- **Exceptions:** None.

### L28 — README Completeness
- **Rule:** README.md MUST include installation instructions, configuration details, and documentation of all available MCP tools with examples.
- **Rationale:** The README is the primary entry point for users. Incomplete README hinders adoption and usability.
- **Enforcement:** Code review must verify README is updated when tools are added/changed. README must be tested by following its instructions.
- **Scope:** All user-facing documentation in README.
- **Exceptions:** None.

### L29 — Documentation Reconciliation in Every Phase
- **Rule:** Documentation MUST be reconciled with code changes before a Phase can be marked complete.
- **Rationale:** Stale documentation is a defect. Documentation must remain a living, accurate source of truth.
- **Enforcement:** Overseer must verify that `.ushabti/docs` reflects code changes during Phase review. Phase cannot achieve GREEN status without docs reconciliation.
- **Scope:** All Phases.
- **Exceptions:** None.

### L30 — Scribe Docs Consultation
- **Rule:** Scribe MUST consult `.ushabti/docs` when planning Phases.
- **Rationale:** Understanding documented systems is prerequisite to coherent planning. Ignoring existing documentation leads to redundant or conflicting work.
- **Enforcement:** Scribe must explicitly reference consulted documentation in Phase plans.
- **Scope:** All Phase planning.
- **Exceptions:** None.

### L31 — Builder Docs Usage and Maintenance
- **Rule:** Builder MUST consult `.ushabti/docs` during implementation and MUST update docs when code changes affect documented systems.
- **Rationale:** Docs are both a resource and a maintenance responsibility. Ignoring docs during implementation produces drift.
- **Enforcement:** Builder must reference relevant docs when implementing. Builder must update docs as part of implementation work when changes affect documented systems.
- **Scope:** All implementation work.
- **Exceptions:** None.

### L32 — Overseer Docs Reconciliation
- **Rule:** Overseer MUST verify that docs are reconciled with code changes before declaring a Phase complete.
- **Rationale:** Stale docs are defects equivalent to failing tests.
- **Enforcement:** Overseer review checklist must include docs reconciliation verification. Phase cannot be GREEN without docs reconciliation.
- **Scope:** All Phase reviews.
- **Exceptions:** None.
