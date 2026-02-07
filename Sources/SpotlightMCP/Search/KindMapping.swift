import Foundation
@preconcurrency import CoreServices
import UniformTypeIdentifiers

/// Maps user-friendly kind names to UTI-based predicates.
public struct KindMapping {
    public static func predicate(forKind kind: String) -> NSPredicate? {
        guard let uti = mapKindToUTI(kind) else {
            return nil
        }

        return buildUTIPredicate(uti)
    }

    private static func mapKindToUTI(_ kind: String) -> UTType? {
        switch kind.lowercased() {
        case "document": return .data
        case "image": return .image
        case "video": return .movie
        case "audio": return .audio
        case "pdf": return .pdf
        case "code": return .sourceCode
        default: return nil
        }
    }

    private static func buildUTIPredicate(_ uti: UTType) -> NSPredicate {
        NSPredicate(
            format: "kMDItemContentTypeTree == %@",
            uti.identifier
        )
    }
}
