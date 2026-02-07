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
}
