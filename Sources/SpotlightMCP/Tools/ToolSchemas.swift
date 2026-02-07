import MCP

/// Defines the MCP tool schemas for all Spotlight tools.
struct ToolSchemas {
    static func all() -> [Tool] {
        [search, getMetadata, searchByKind, recentFiles]
    }

    static let search = Tool(
        name: "search",
        description: "Search for files by text content within a directory scope.",
        inputSchema: searchSchema,
        annotations: .init(readOnlyHint: true)
    )

    static let getMetadata = Tool(
        name: "get_metadata",
        description: "Get Spotlight metadata attributes for a specific file.",
        inputSchema: getMetadataSchema,
        annotations: .init(readOnlyHint: true)
    )

    static let searchByKind = Tool(
        name: "search_by_kind",
        description: "Search for files by kind (document, image, video, audio, pdf, code).",
        inputSchema: searchByKindSchema,
        annotations: .init(readOnlyHint: true)
    )

    static let recentFiles = Tool(
        name: "recent_files",
        description: "Find recently modified files within a directory scope.",
        inputSchema: recentFilesSchema,
        annotations: .init(readOnlyHint: true)
    )
}
