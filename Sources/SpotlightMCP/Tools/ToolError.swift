import Foundation

/// Errors that can occur during tool execution.
public enum ToolError: Error, Equatable, Sendable {
    case unknownTool(String)
    case missingArgument(String)
    case invalidArgument(String)
    case fileNotFound(String)
    case queryFailed(String)
}

extension ToolError {
    var message: String {
        switch self {
        case .unknownTool(let name):
            return "Unknown tool: \(name)"
        case .missingArgument(let name):
            return "Missing required argument: \(name)"
        case .invalidArgument(let detail):
            return "Invalid argument: \(detail)"
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .queryFailed(let detail):
            return "Query failed: \(detail)"
        }
    }
}
