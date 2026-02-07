import MCP

/// Extracts and validates tool arguments from MCP Value dictionaries.
struct ArgumentParser: Sendable {
    private let arguments: [String: Value]

    init(_ arguments: [String: Value]?) {
        self.arguments = arguments ?? [:]
    }

    func requireString(_ key: String) throws(ToolError) -> String {
        guard let value = arguments[key] else {
            throw .missingArgument(key)
        }
        return try extractString(key, value)
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
}
