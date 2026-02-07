import Foundation

/// Errors that can occur during query building.
public enum BuilderError: Error, Equatable, Sendable {
    case invalidPredicate(String)
}

/// Constructs NSPredicate from structured search parameters.
public struct QueryBuilder: Sendable {
    public init() {}

    public func naturalText(_ text: String) -> NSPredicate {
        buildTextPredicate(text)
    }

    public func rawPredicate(_ predicateString: String) throws(BuilderError) -> NSPredicate {
        try parseRawPredicate(predicateString)
    }

    public func kind(_ kind: String) -> NSPredicate? {
        KindMapping.predicate(forKind: kind)
    }

    public func modifiedSince(_ isoDate: String) -> String {
        "kMDItemContentModificationDate >= $time.iso(\(isoDate))"
    }

    private func buildTextPredicate(_ text: String) -> NSPredicate {
        NSPredicate(
            format: "kMDItemTextContent ==[cd] %@",
            "*\(text)*" as NSString
        )
    }

    private func parseRawPredicate(_ predicateString: String) throws(BuilderError) -> NSPredicate {
        guard !predicateString.isEmpty else {
            throw .invalidPredicate("Predicate string cannot be empty")
        }

        return NSPredicate(format: predicateString)
    }
}
