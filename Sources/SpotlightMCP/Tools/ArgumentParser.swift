import Foundation
import MCP

/// Extracts and validates tool arguments from MCP Value dictionaries.
struct ArgumentParser: Sendable {
    private let arguments: [String: Value]
    private let sanitizer = PathSanitizer()

    init(_ arguments: [String: Value]?) {
        self.arguments = arguments ?? [:]
    }

    func requireString(_ key: String) throws(ToolError) -> String {
        guard let value = arguments[key] else {
            throw .missingArgument(key)
        }
        return try extractString(key, value)
    }

    func requireAbsolutePath(_ key: String) throws(ToolError) -> String {
        let path = try requireString(key)
        try validateAbsolutePath(path, key: key)
        return path
    }

    func requireValidatedScope(_ key: String) throws(ToolError) -> String {
        let path = try requireAbsolutePath(key)
        try sanitizer.validateScope(path)
        return path
    }

    func optionalString(_ key: String) -> String? {
        arguments[key]?.stringValue
    }

    func optionalInt(_ key: String) -> Int? {
        arguments[key]?.intValue
    }
}

extension ArgumentParser {
    private func extractString(
        _ key: String,
        _ value: Value
    ) throws(ToolError) -> String {
        guard let string = value.stringValue, !string.isEmpty else {
            throw .invalidArgument("\(key) must be a non-empty string")
        }
        return string
    }

    private func validateAbsolutePath(
        _ path: String,
        key: String
    ) throws(ToolError) {
        guard path.hasPrefix("/") else {
            let msg = "\(key) must be an absolute path (starting with /)"
            throw .invalidArgument(msg)
        }
    }
}
