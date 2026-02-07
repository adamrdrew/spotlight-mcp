import Testing
import Foundation
@testable import SpotlightMCP

@Suite("SpotlightQuery Integration Tests")
struct SpotlightQueryTests {

    @Test("execute completes successfully")
    func executeCompletesSuccessfully() throws {
        let predicate = NSPredicate(format: "kMDItemDisplayName == \"*.swift\"")
        let homeDirectory = URL(fileURLWithPath: NSHomeDirectory())
        let query = SpotlightQuery(predicate: predicate, scope: [homeDirectory])

        let results = try query.execute()

        #expect(results.count >= 0)
    }

    @Test("MetadataItem extracts attributes from results")
    func metadataItemExtractsAttributesFromResults() throws {
        let predicate = NSPredicate(format: "kMDItemContentType == \"public.swift-source\"")
        let projectDirectory = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        let query = SpotlightQuery(predicate: predicate, scope: [projectDirectory])

        let results = try query.execute()

        if !results.isEmpty {
            verifyPathExtraction(results)
            verifyMetadataExtraction(results)
        }
    }

    @Test("execute throws on empty scope")
    func executeThrowsOnEmptyScope() {
        let predicate = NSPredicate(format: "kMDItemDisplayName == \"test.txt\"")
        let query = SpotlightQuery(predicate: predicate, scope: [])

        #expect(throws: QueryError.invalidScope) {
            try query.execute()
        }
    }

    private func verifyPathExtraction(_ results: [SearchResult]) {
        for result in results {
            #expect(!result.path.path.isEmpty)
            #expect(result.path.isFileURL)
        }
    }

    private func verifyMetadataExtraction(_ results: [SearchResult]) {
        for result in results {
            #expect(!result.metadata.isEmpty)
        }
    }
}
