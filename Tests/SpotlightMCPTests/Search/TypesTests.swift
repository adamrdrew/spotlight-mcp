import Testing
import Foundation
@testable import SpotlightMCP

@Suite("MetadataValue Codable Tests")
struct TypesTests {

    @Test("Encode string case")
    func encodeString() throws {
        let value = MetadataValue.string("test")
        let encoded = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(String.self, from: encoded)
        #expect(decoded == "test")
    }

    @Test("Encode int case")
    func encodeInt() throws {
        let value = MetadataValue.int(42)
        let encoded = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(Int.self, from: encoded)
        #expect(decoded == 42)
    }

    @Test("Encode double case")
    func encodeDouble() throws {
        let value = MetadataValue.double(3.14)
        let encoded = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(Double.self, from: encoded)
        #expect(decoded == 3.14)
    }

    @Test("Encode date case")
    func encodeDate() throws {
        let date = Date(timeIntervalSince1970: 1704067200)
        let value = MetadataValue.date(date)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let encoded = try encoder.encode(value)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let decoded = try decoder.decode(Date.self, from: encoded)
        #expect(abs(decoded.timeIntervalSince(date)) < 1.0)
    }

    @Test("Encode array case")
    func encodeArray() throws {
        let value = MetadataValue.array([.string("a"), .int(1)])
        let encoded = try JSONEncoder().encode(value)
        let json = try JSONSerialization.jsonObject(with: encoded, options: []) as? [Any]
        #expect(json != nil)
        #expect(json?.count == 2)
    }

    @Test("Encode dictionary case")
    func encodeDictionary() throws {
        let value = MetadataValue.dictionary(["key": .string("value")])
        let encoded = try JSONEncoder().encode(value)
        let json = try JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any]
        #expect(json != nil)
        #expect(json?["key"] as? String == "value")
    }

    @Test("Decode string case")
    func decodeString() throws {
        let json = "\"test\"".data(using: .utf8)!
        let value = try JSONDecoder().decode(MetadataValue.self, from: json)
        #expect(value == .string("test"))
    }

    @Test("Decode int case")
    func decodeInt() throws {
        let json = "42".data(using: .utf8)!
        let value = try JSONDecoder().decode(MetadataValue.self, from: json)
        #expect(value == .int(42))
    }

    @Test("Decode double case")
    func decodeDouble() throws {
        let json = "3.14".data(using: .utf8)!
        let value = try JSONDecoder().decode(MetadataValue.self, from: json)
        #expect(value == .double(3.14))
    }

    @Test("Decode array case")
    func decodeArray() throws {
        let json = "[\"a\",1]".data(using: .utf8)!
        let value = try JSONDecoder().decode(MetadataValue.self, from: json)
        #expect(value == .array([.string("a"), .int(1)]))
    }

    @Test("Decode dictionary case")
    func decodeDictionary() throws {
        let json = "{\"key\":\"value\"}".data(using: .utf8)!
        let value = try JSONDecoder().decode(MetadataValue.self, from: json)
        #expect(value == .dictionary(["key": .string("value")]))
    }

    @Test("Round-trip string")
    func roundTripString() throws {
        let original = MetadataValue.string("test")
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MetadataValue.self, from: encoded)
        #expect(decoded == original)
    }

    @Test("Round-trip int")
    func roundTripInt() throws {
        let original = MetadataValue.int(42)
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MetadataValue.self, from: encoded)
        #expect(decoded == original)
    }

    @Test("Round-trip double")
    func roundTripDouble() throws {
        let original = MetadataValue.double(3.14)
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MetadataValue.self, from: encoded)
        #expect(decoded == original)
    }

    @Test("Round-trip array")
    func roundTripArray() throws {
        let original = MetadataValue.array([.string("a"), .int(1), .double(2.5)])
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MetadataValue.self, from: encoded)
        #expect(decoded == original)
    }

    @Test("Round-trip dictionary")
    func roundTripDictionary() throws {
        let original = MetadataValue.dictionary([
            "string": .string("value"),
            "int": .int(42),
            "double": .double(3.14)
        ])
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MetadataValue.self, from: encoded)
        #expect(decoded == original)
    }

    @Test("Decode invalid data throws")
    func decodeInvalidData() {
        let json = "null".data(using: .utf8)!
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(MetadataValue.self, from: json)
        }
    }
}
