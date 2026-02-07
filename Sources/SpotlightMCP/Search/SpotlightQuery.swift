import Foundation
@preconcurrency import CoreServices

/// Errors that can occur during query execution.
public enum QueryError: Error, Equatable, Sendable {
    case executionFailed
    case invalidScope
}

/// Wraps MDQuery for type-safe Spotlight query execution.
public struct SpotlightQuery {
    public let queryString: String
    public let scope: [URL]

    public init(
        predicate: NSPredicate,
        scope: [URL]
    ) {
        self.queryString = predicate.predicateFormat
        self.scope = scope
    }

    public init(
        queryString: String,
        scope: [URL]
    ) {
        self.queryString = queryString
        self.scope = scope
    }

    public func execute() throws(QueryError) -> [SearchResult] {
        try performQuery()
    }

    private func performQuery() throws(QueryError) -> [SearchResult] {
        try validateScope()
        let query = try createAndExecuteQuery()
        return collectResults(from: query)
    }

    private func validateScope() throws(QueryError) {
        guard !scope.isEmpty else {
            throw .invalidScope
        }
    }

    private func createAndExecuteQuery() throws(QueryError) -> MDQuery {
        guard let query = createQuery() else {
            throw .executionFailed
        }
        try execute(query: query)
        return query
    }

    private func execute(query: MDQuery) throws(QueryError) {
        guard executeQuery(query) else {
            throw .executionFailed
        }
    }

    private func createQuery() -> MDQuery? {
        MDQueryCreate(kCFAllocatorDefault, queryString as CFString, nil, nil)
    }

    private func executeQuery(_ query: MDQuery) -> Bool {
        MDQuerySetSearchScope(query, scope as CFArray, 0)
        let flags = CFOptionFlags(kMDQuerySynchronous.rawValue)
        return MDQueryExecute(query, flags)
    }

    private func collectResults(from query: MDQuery) -> [SearchResult] {
        let count = MDQueryGetResultCount(query)
        return (0..<count).compactMap { buildResult(query, $0) }
    }

    private func buildResult(_ query: MDQuery, _ index: Int) -> SearchResult? {
        guard let itemPointer = MDQueryGetResultAtIndex(query, index) else {
            return nil
        }
        return extractResult(from: itemPointer)
    }

    private func extractResult(from pointer: UnsafeRawPointer) -> SearchResult? {
        let item = Unmanaged<MDItem>.fromOpaque(pointer).takeUnretainedValue()
        return createSearchResult(item)
    }

    private func createSearchResult(_ item: MDItem) -> SearchResult? {
        let metadata = MetadataItem(item: item)
        guard let path = extractPath(from: metadata) else {
            return nil
        }
        return buildSearchResult(path: path, metadata: metadata)
    }

    private func extractPath(from metadata: MetadataItem) -> URL? {
        guard let pathValue = metadata.getAttribute(kMDItemPath as String),
              case .string(let pathString) = pathValue else {
            return nil
        }
        return URL(fileURLWithPath: pathString)
    }

    private func buildSearchResult(path: URL, metadata: MetadataItem) -> SearchResult {
        SearchResult(
            path: path,
            metadata: metadata.getAllAttributes()
        )
    }
}
