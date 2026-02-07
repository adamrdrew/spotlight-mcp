import Testing
@testable import SpotlightMCP

@Suite("QueryBuilder Tests")
struct QueryBuilderTests {
    let builder = QueryBuilder()

    @Test("naturalText produces text content predicate")
    func naturalTextProducesTextContentPredicate() {
        let predicate = builder.naturalText("test")
        let expected = "kMDItemTextContent CONTAINS[cd] \"test\""

        #expect(predicate.predicateFormat == expected)
    }

    @Test("rawPredicate parses valid predicate")
    func rawPredicateParsesValidPredicate() throws {
        let predicateString = "kMDItemDisplayName == \"test.txt\""
        let predicate = try builder.rawPredicate(predicateString)

        #expect(predicate.predicateFormat == predicateString)
    }

    @Test("rawPredicate throws on empty string")
    func rawPredicateThrowsOnEmptyString() {
        #expect(throws: BuilderError.self) {
            try builder.rawPredicate("")
        }
    }

    @Test("kind delegates to KindMapping")
    func kindDelegatesToKindMapping() {
        let predicate = builder.kind("image")

        #expect(predicate != nil)
    }

    @Test("kind returns nil for unknown kind")
    func kindReturnsNilForUnknownKind() {
        let predicate = builder.kind("unknown")

        #expect(predicate == nil)
    }
}
