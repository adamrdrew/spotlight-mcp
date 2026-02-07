# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

An MCP server in Swift that exposes macOS Spotlight search to LLMs via stdio JSON-RPC. Four tools: `search`, `get_metadata`, `search_by_kind`, `recent_files`.

## Build & Test Commands

```bash
swift build                    # Debug build
swift build -c release         # Release build
swift test                     # Run all tests (90 tests, Swift Testing framework)
swift test --filter SearchTool # Run tests matching a name
```

## Architecture

Two layers under `Sources/SpotlightMCP/`:

**Search/** — Spotlight API abstraction (Phase 2). Wraps MDQuery/MDItem into type-safe Swift:
- `SpotlightQuery` executes queries (accepts NSPredicate or raw MDQuery string)
- `QueryBuilder` constructs predicates from structured params (text, kind, date)
- `MetadataItem` extracts MDItem attributes into `MetadataValue` enum
- `KindMapping` maps friendly names ("image", "code") to UTI predicates
- `Types.swift` defines `SearchResult` and `MetadataValue`; `MetadataValue+Codable.swift` has custom Codable

**Tools/** — MCP tool handlers (Phase 3) + hardening (Phase 4). Connects MCP protocol to Search layer:
- `ToolRouter` dispatches `CallTool` by name to the right handler; logs invocations via swift-log
- Each tool struct has a `handle(ArgumentParser) throws(ToolError) -> CallTool.Result`
- `ArgumentParser` extracts/validates args from `[String: Value]` (absolute path enforcement, scope validation)
- `PathSanitizer` resolves symlinks and enforces scope boundaries (L07)
- `PaginationConfig` enforces limits (default 100, max 1000)
- `ResultFormatter` serializes results as JSON with ISO 8601 dates
- `ToolSchemas` + `ToolSchemas+Definitions` define ListTools responses

**main.swift** — Wires Server, ToolSchemas, ToolRouter (with Logger), and StdioTransport.

## Key Constraint: MDQuery vs NSPredicate

MDQuery and NSPredicate have different predicate dialects. NSPredicate date serialization (`CAST(timestamp, "NSDate")`) and `$time.iso()` are mutually incompatible. `SpotlightQuery` accepts both an NSPredicate (via `.predicateFormat`) and a raw query string for MDQuery-only syntax. Date predicates must use the raw string path.

## Enforced Rules

Read `.ushabti/laws.md` and `.ushabti/style.md` for the full list. The critical ones:

- **Swift 6 language mode** — strict concurrency, all types must be Sendable
- **Sandi Metz rules** — types ≤100 lines (excluding blanks/comments), methods ≤5 lines, ≤4 parameters
- **Typed throws** — all error-throwing functions specify the error type
- **Explicit search scope** — no tool may search without a `scope` parameter (no system-wide)
- **Structured JSON only** — tools return JSON via ResultFormatter, never raw strings
- **Absolute paths only** — all file paths in responses must be absolute
- **ISO 8601 dates** — all date params and response values
- **Swift Testing** (not XCTest) — every public method needs at least one test
- **No private APIs** — only public CoreServices/Foundation frameworks

## Ushabti Workflow

This project uses the Ushabti development framework (`.ushabti/`). Phases are planned by Scribe, built by Builder, reviewed by Overseer. Phase state lives in `.ushabti/phases/NNNN-slug/progress.yaml`. Documentation in `.ushabti/docs/` must be reconciled each phase.

## Test Structure

Tests mirror source layout: `Tests/SpotlightMCPTests/Search/` and `Tests/SpotlightMCPTests/Tools/`. Tool handler tests exercise both success paths (hitting real Spotlight) and error paths (missing args, invalid inputs). Use `@testable import SpotlightMCP` and `import MCP` for access to Value types.
