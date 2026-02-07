import Foundation
@preconcurrency import CoreServices
import MCP

/// Handles the `get_metadata` tool — retrieve metadata for a specific file.
struct GetMetadataTool: Sendable {
    func handle(_ args: ArgumentParser) throws(ToolError) -> CallTool.Result {
        let path = try args.requireString("path")
        try validateAbsolutePath(path)
        try validateFileExists(path)
        let metadata = try extractMetadata(path)
        return .init(content: [ResultFormatter.format(metadata)])
    }
}

extension GetMetadataTool {
    private func validateAbsolutePath(_ path: String) throws(ToolError) {
        guard path.hasPrefix("/") else {
            throw .invalidArgument("path must be absolute (start with /)")
        }
    }

    private func validateFileExists(_ path: String) throws(ToolError) {
        guard FileManager.default.fileExists(atPath: path) else {
            throw .fileNotFound(path)
        }
    }

    private func extractMetadata(_ path: String) throws(ToolError) -> [String: MetadataValue] {
        guard let mdItem = MDItemCreate(kCFAllocatorDefault, path as CFString) else {
            throw .queryFailed("Unable to read metadata for: \(path)")
        }
        return MetadataItem(item: mdItem).getAllAttributes()
    }
}
