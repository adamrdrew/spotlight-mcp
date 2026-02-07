import Foundation

/// Sanitizes and validates file paths per L07.
struct PathSanitizer: Sendable {
    func sanitize(
        _ path: String,
        within scope: String
    ) throws(ToolError) -> URL {
        let pathURL = try resolveToAbsoluteURL(path)
        let scopeURL = try resolveToAbsoluteURL(scope)
        try validateWithinScope(pathURL, scope: scopeURL)
        return pathURL
    }

    func validateScope(_ scope: String) throws(ToolError) {
        let scopeURL = try resolveToAbsoluteURL(scope)
        try validateScopeExists(scopeURL)
    }
}

extension PathSanitizer {
    private func resolveToAbsoluteURL(
        _ path: String
    ) throws(ToolError) -> URL {
        let url = URL(fileURLWithPath: path)
        return url.resolvingSymlinksInPath().standardized
    }

    private func validateWithinScope(
        _ path: URL,
        scope: URL
    ) throws(ToolError) {
        let pathStr = path.path
        let scopeStr = scope.path
        guard pathStr.hasPrefix(scopeStr) else {
            let msg = "Path outside scope: \(pathStr)"
            throw .invalidArgument(msg)
        }
    }

    private func validateScopeExists(_ scope: URL) throws(ToolError) {
        var isDirectory: ObjCBool = false
        let exists = FileManager.default.fileExists(
            atPath: scope.path,
            isDirectory: &isDirectory
        )
        guard exists, isDirectory.boolValue else {
            throw .invalidArgument("Scope is not a directory: \(scope.path)")
        }
    }
}
