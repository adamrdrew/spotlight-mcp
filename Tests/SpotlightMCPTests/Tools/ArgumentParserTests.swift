import Foundation
import Testing
import MCP
@testable import SpotlightMCP

@Suite("ArgumentParser Tests")
struct ArgumentParserTests {
    @Test("requireString returns value for valid key")
    func requireStringReturnsValueForValidKey() throws {
        let parser = ArgumentParser(["name": .string("test")])
        let result = try parser.requireString("name")
        #expect(result == "test")
    }

    @Test("requireString throws for missing key")
    func requireStringThrowsForMissingKey() {
        let parser = ArgumentParser([:])
        #expect(throws: ToolError.self) {
            try parser.requireString("name")
        }
    }

    @Test("requireString throws for empty string")
    func requireStringThrowsForEmptyString() {
        let parser = ArgumentParser(["name": .string("")])
        #expect(throws: ToolError.self) {
            try parser.requireString("name")
        }
    }

    @Test("requireString throws for non-string value")
    func requireStringThrowsForNonStringValue() {
        let parser = ArgumentParser(["name": .int(42)])
        #expect(throws: ToolError.self) {
            try parser.requireString("name")
        }
    }

    @Test("optionalString returns value when present")
    func optionalStringReturnsValueWhenPresent() {
        let parser = ArgumentParser(["key": .string("val")])
        #expect(parser.optionalString("key") == "val")
    }

    @Test("optionalString returns nil when missing")
    func optionalStringReturnsNilWhenMissing() {
        let parser = ArgumentParser([:])
        #expect(parser.optionalString("key") == nil)
    }

    @Test("optionalInt returns value when present")
    func optionalIntReturnsValueWhenPresent() {
        let parser = ArgumentParser(["limit": .int(50)])
        #expect(parser.optionalInt("limit") == 50)
    }

    @Test("optionalInt returns nil when missing")
    func optionalIntReturnsNilWhenMissing() {
        let parser = ArgumentParser([:])
        #expect(parser.optionalInt("limit") == nil)
    }

    @Test("init handles nil arguments")
    func initHandlesNilArguments() {
        let parser = ArgumentParser(nil)
        #expect(parser.optionalString("any") == nil)
    }

    @Test("requireAbsolutePath accepts absolute path")
    func requireAbsolutePathAcceptsAbsolutePath() throws {
        let parser = ArgumentParser(["path": .string("/tmp/test")])
        let result = try parser.requireAbsolutePath("path")
        #expect(result == "/tmp/test")
    }

    @Test("requireAbsolutePath rejects relative path")
    func requireAbsolutePathRejectsRelativePath() {
        let parser = ArgumentParser(["path": .string("relative/path")])
        #expect(throws: ToolError.invalidArgument("path must be an absolute path (starting with /)")) {
            try parser.requireAbsolutePath("path")
        }
    }

    @Test("requireAbsolutePath rejects path with ../")
    func requireAbsolutePathRejectsPathWithDotDot() {
        let parser = ArgumentParser(["path": .string("../etc/passwd")])
        #expect(throws: ToolError.invalidArgument("path must be an absolute path (starting with /)")) {
            try parser.requireAbsolutePath("path")
        }
    }

    @Test("requireValidatedScope accepts valid directory")
    func requireValidatedScopeAcceptsValidDirectory() throws {
        let parser = ArgumentParser(["scope": .string("/tmp")])
        let result = try parser.requireValidatedScope("scope")
        #expect(result == "/tmp")
    }

    @Test("requireValidatedScope rejects non-existent directory")
    func requireValidatedScopeRejectsNonExistentDirectory() {
        let path = "/nonexistent/\(UUID().uuidString)"
        let parser = ArgumentParser(["scope": .string(path)])
        #expect(throws: ToolError.self) {
            try parser.requireValidatedScope("scope")
        }
    }
}
