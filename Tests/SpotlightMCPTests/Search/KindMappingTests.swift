import Testing
import UniformTypeIdentifiers
@testable import SpotlightMCP

@Suite("KindMapping Tests")
struct KindMappingTests {

    @Test("predicate for document kind")
    func predicateForDocumentKind() {
        let predicate = KindMapping.predicate(forKind: "document")

        #expect(predicate != nil)
        verifyUTIPredicate(predicate, .data)
    }

    @Test("predicate for image kind")
    func predicateForImageKind() {
        let predicate = KindMapping.predicate(forKind: "image")

        #expect(predicate != nil)
        verifyUTIPredicate(predicate, .image)
    }

    @Test("predicate for video kind")
    func predicateForVideoKind() {
        let predicate = KindMapping.predicate(forKind: "video")

        #expect(predicate != nil)
        verifyUTIPredicate(predicate, .movie)
    }

    @Test("predicate for audio kind")
    func predicateForAudioKind() {
        let predicate = KindMapping.predicate(forKind: "audio")

        #expect(predicate != nil)
        verifyUTIPredicate(predicate, .audio)
    }

    @Test("predicate for pdf kind")
    func predicateForPDFKind() {
        let predicate = KindMapping.predicate(forKind: "pdf")

        #expect(predicate != nil)
        verifyUTIPredicate(predicate, .pdf)
    }

    @Test("predicate for code kind")
    func predicateForCodeKind() {
        let predicate = KindMapping.predicate(forKind: "code")

        #expect(predicate != nil)
        verifyUTIPredicate(predicate, .sourceCode)
    }

    @Test("predicate returns nil for unknown kind")
    func predicateReturnsNilForUnknownKind() {
        let predicate = KindMapping.predicate(forKind: "unknown")

        #expect(predicate == nil)
    }

    @Test("predicate is case insensitive")
    func predicateIsCaseInsensitive() {
        let lower = KindMapping.predicate(forKind: "image")
        let upper = KindMapping.predicate(forKind: "IMAGE")

        #expect(lower?.predicateFormat == upper?.predicateFormat)
    }

    private func verifyUTIPredicate(_ predicate: NSPredicate?, _ uti: UTType) {
        guard let predicate = predicate else {
            Issue.record("Predicate is nil")
            return
        }

        let expected = "kMDItemContentTypeTree == \"\(uti.identifier)\""
        #expect(predicate.predicateFormat == expected)
    }
}
