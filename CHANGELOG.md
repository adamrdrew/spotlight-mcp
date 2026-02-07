# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2026-02-07

### Fixed

- Release workflow: Build each architecture separately and combine with lipo to avoid Xcode build system duplicate output errors on GitHub Actions

## [0.1.0] - 2026-02-07

### Added

- MCP server infrastructure with stdio transport for JSON-RPC communication
- Four Spotlight search tools:
  - `search` - Full-text search across file contents within a directory
  - `get_metadata` - Retrieve Spotlight metadata for a specific file
  - `search_by_kind` - Find files by type (document, image, video, audio, pdf, code)
  - `recent_files` - Find files modified after a given date
- Spotlight query abstraction layer:
  - `SpotlightQuery` - Type-safe MDQuery execution wrapper
  - `QueryBuilder` - Structured predicate construction from parameters
  - `MetadataItem` - MDItem attribute extraction with type safety
  - `KindMapping` - User-friendly type names to UTI predicate mapping
  - Custom Codable implementation for MetadataValue enum
- MCP tool handler system:
  - `ToolRouter` - Request dispatching with structured logging
  - Tool-specific handlers for each search operation
  - `ToolSchemas` - ListTools response definitions
- Input validation and security hardening:
  - `ArgumentParser` - Validates and extracts MCP arguments
  - `PathSanitizer` - Prevents directory traversal and enforces scope boundaries (L07)
  - Absolute path requirement for all file operations
  - Explicit search scope requirement (no system-wide searches)
- Result formatting and pagination:
  - `PaginationConfig` - Enforces result limits (default 100, max 1000)
  - `ResultFormatter` - Structured JSON output with ISO 8601 dates
  - Absolute file paths in all responses
- Error handling:
  - Typed error enum (`ToolError`) for all tool operations
  - Descriptive error messages for validation failures
  - Graceful handling of edge cases (zero results, missing files, invalid inputs)
- Logging infrastructure using swift-log:
  - Operational event logging (server start/stop, tool invocations)
  - Minimal result logging (L08 compliance)
  - Configurable log levels (error, warning, info, debug)
- Homebrew distribution:
  - Automated GitHub Actions workflow for universal binary builds (arm64 + x86_64)
  - GitHub Release creation with tarball artifacts
  - Automated Homebrew tap repository updates
  - Formula with binary installation and executable verification test
- Comprehensive documentation:
  - Installation instructions (Homebrew and source builds)
  - Tool reference with parameter details and usage examples
  - Security model documentation
  - Troubleshooting guide
  - Development and build instructions
  - MCP client configuration examples

### Fixed

- Case-sensitive search behavior (Phase 5) - Text search now uses case-insensitive matching
- MDQuery syntax compatibility (Phase 6) - Date predicates use raw MDQuery strings to avoid NSPredicate serialization issues

[unreleased]: https://github.com/adamrdrew/spotlight-mcp/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/adamrdrew/spotlight-mcp/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/adamrdrew/spotlight-mcp/releases/tag/v0.1.0
