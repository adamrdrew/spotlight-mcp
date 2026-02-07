import Foundation
import Testing
@testable import SpotlightMCP

@Suite("PathSanitizer Tests")
struct PathSanitizerTests {
    let sanitizer = PathSanitizer()

    @Test("sanitize accepts path within scope")
    func sanitizeAcceptsPathWithinScope() throws {
        let result = try sanitizer.sanitize("/tmp/test", within: "/tmp")
        #expect(result.path.hasPrefix("/tmp"))
    }

    @Test("sanitize rejects path outside scope")
    func sanitizeRejectsPathOutsideScope() {
        #expect(throws: ToolError.self) {
            try sanitizer.sanitize("/etc/passwd", within: "/tmp")
        }
    }

    @Test("sanitize resolves and validates symbolic links")
    func sanitizeResolvesAndValidatesSymbolicLinks() throws {
        let tmpDir = FileManager.default.temporaryDirectory
        let linkPath = tmpDir.appendingPathComponent("test-link")
        let targetPath = tmpDir.appendingPathComponent("test-target")

        try FileManager.default.createDirectory(
            at: targetPath,
            withIntermediateDirectories: true
        )
        defer {
            try? FileManager.default.removeItem(at: targetPath)
            try? FileManager.default.removeItem(at: linkPath)
        }

        try FileManager.default.createSymbolicLink(
            at: linkPath,
            withDestinationURL: targetPath
        )

        let result = try sanitizer.sanitize(
            linkPath.path,
            within: tmpDir.path
        )
        #expect(result.path == targetPath.path)
    }

    @Test("validateScope accepts existing directory")
    func validateScopeAcceptsExistingDirectory() throws {
        try sanitizer.validateScope("/tmp")
    }

    @Test("validateScope rejects non-existent directory")
    func validateScopeRejectsNonExistentDirectory() {
        let path = "/nonexistent/\(UUID().uuidString)"
        #expect(throws: ToolError.self) {
            try sanitizer.validateScope(path)
        }
    }

    @Test("validateScope rejects file path")
    func validateScopeRejectsFilePath() throws {
        let tmpDir = FileManager.default.temporaryDirectory
        let filePath = tmpDir.appendingPathComponent("test-file.txt")

        try "test".write(to: filePath, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: filePath) }

        #expect(throws: ToolError.self) {
            try sanitizer.validateScope(filePath.path)
        }
    }
}
