import MCP

extension ToolSchemas {
    static let searchSchema = Value.object([
        "type": .string("object"),
        "properties": .object([
            "query": .object([
                "type": .string("string"),
                "description": .string("Text to search for in file contents"),
            ]),
            "scope": .object([
                "type": .string("string"),
                "description": .string("Absolute path to directory to search within"),
            ]),
            "limit": .object([
                "type": .string("integer"),
                "description": .string("Maximum results to return (default 100, max 1000)"),
            ]),
        ]),
        "required": .array([.string("query"), .string("scope")]),
    ])

    static let getMetadataSchema = Value.object([
        "type": .string("object"),
        "properties": .object([
            "path": .object([
                "type": .string("string"),
                "description": .string("Absolute path to the file"),
            ]),
        ]),
        "required": .array([.string("path")]),
    ])

    static let searchByKindSchema = Value.object([
        "type": .string("object"),
        "properties": .object([
            "kind": .object([
                "type": .string("string"),
                "description": .string("File kind: document, image, video, audio, pdf, code"),
            ]),
            "scope": .object([
                "type": .string("string"),
                "description": .string("Absolute path to directory to search within"),
            ]),
            "limit": .object([
                "type": .string("integer"),
                "description": .string("Maximum results to return (default 100, max 1000)"),
            ]),
        ]),
        "required": .array([.string("kind"), .string("scope")]),
    ])

    static let recentFilesSchema = Value.object([
        "type": .string("object"),
        "properties": .object([
            "scope": .object([
                "type": .string("string"),
                "description": .string("Absolute path to directory to search within"),
            ]),
            "since": .object([
                "type": .string("string"),
                "description": .string("ISO 8601 date; only files modified after this date (default: 7 days ago)"),
            ]),
            "limit": .object([
                "type": .string("integer"),
                "description": .string("Maximum results to return (default 100, max 1000)"),
            ]),
        ]),
        "required": .array([.string("scope")]),
    ])
}
