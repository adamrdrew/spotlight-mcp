# Manual End-to-End Test — Phase 0003

## Environment

- **Date**: 2026-02-06
- **macOS**: Darwin 25.2.0 (arm64)
- **Swift**: 6.2.3
- **Branch**: phase-0004-spotlight-wiring

## Setup

```bash
swift build
```

## Test Procedure

All tests use stdio JSON-RPC. Messages are piped to `swift run spotlight-mcp` with a trailing sleep to allow query execution before stdin closes.

### Test 1: Initialize

**Request**:
```json
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}
```

**Result**: OK — returned server info with capabilities.

### Test 2: tools/list

**Request**:
```json
{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}
```

**Result**: OK — returned 4 tools: `search`, `get_metadata`, `search_by_kind`, `recent_files`. All have input schemas with required/optional parameters, descriptions, and `readOnlyHint: true` annotations.

### Test 3: search tool

**Request**:
```json
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"search","arguments":{"query":"import","scope":"/Users/adam/Development/spotlight-mcp/Sources","limit":2}}}
```

**Result**: OK — returned 2 results (respecting limit). Each result contains `_path` (absolute) and full metadata including `kMDItemContentType`, `kMDItemDisplayName`, dates in ISO 8601 format.

### Test 4: get_metadata tool

**Request**:
```json
{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"get_metadata","arguments":{"path":"/Users/adam/Development/spotlight-mcp/Package.swift"}}}
```

**Result**: OK — returned metadata dictionary with keys including `kMDItemContentType: "public.swift-source"`, `kMDItemFSSize`, `kMDItemContentModificationDate` (ISO 8601).

### Test 5: search_by_kind tool

**Request**:
```json
{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"search_by_kind","arguments":{"kind":"code","scope":"/Users/adam/Development/spotlight-mcp/Sources","limit":2}}}
```

**Result**: OK — returned 2 Swift source files with absolute paths and metadata.

### Test 6: recent_files tool

**Request**:
```json
{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"recent_files","arguments":{"scope":"/Users/adam/Development/spotlight-mcp/Sources","since":"2026-01-01T00:00:00Z","limit":2}}}
```

**Result**: OK — returned 2 recently modified items with absolute paths and metadata.

### Test 7: Error cases

| Request | Expected | Actual |
|---------|----------|--------|
| Unknown tool `"nonexistent"` | `isError: true`, "Unknown tool" | OK |
| search missing scope | `isError: true`, "Missing required argument: scope" | OK |
| get_metadata relative path `"relative/path"` | `isError: true`, "path must be absolute" | OK |
| get_metadata nonexistent `"/nonexistent/file.txt"` | `isError: true`, "File not found" | OK |
| recent_files bad date `"not-a-date"` | `isError: true`, "Invalid ISO 8601 date" | OK |
| search_by_kind unknown kind `"spreadsheet"` | `isError: true`, "Unknown kind" | OK |

All 6 error cases returned structured error responses with `isError: true` and descriptive messages.

## Verification Summary

| Acceptance Criterion | Status |
|---------------------|--------|
| 1. ListTools returns four tools | PASS |
| 2. Search tool works | PASS |
| 3. Get metadata tool works | PASS |
| 4. Search by kind tool works | PASS |
| 5. Recent files tool works | PASS |
| 6. Pagination enforced | PASS (limit=2 respected) |
| 7. Absolute paths | PASS |
| 8. Error handling | PASS (6 error cases) |
| 9. Tool routing works | PASS |
| 10. Manual test passes | PASS |
