import Foundation
import MCP

/// Handles the `search_by_kind` tool — search files by content type.
struct SearchByKindTool: Sendable {
    private let builder: QueryBuilder

    init(builder: QueryBuilder = QueryBuilder()) {
        self.builder = builder
    }

    func handle(_ args: ArgumentParser) throws(ToolError) -> CallTool.Result {
        let kind = try args.requireString("kind")
        let scopePath = try args.requireString("scope")
        let pagination = PaginationConfig(requested: args.optionalInt("limit"))
        let results = try executeKindSearch(kind, scopePath)
        let paginated = pagination.apply(to: results)
        return .init(content: [ResultFormatter.format(paginated)])
    }
}

extension SearchByKindTool {
    private func executeKindSearch(
        _ kind: String,
        _ scopePath: String
    ) throws(ToolError) -> [SearchResult] {
        guard let predicate = builder.kind(kind) else {
            throw .invalidArgument("Unknown kind: \(kind)")
        }
        let scope = [URL(fileURLWithPath: scopePath)]
        let query = SpotlightQuery(predicate: predicate, scope: scope)
        return try runQuery(query)
    }

    private func runQuery(_ query: SpotlightQuery) throws(ToolError) -> [SearchResult] {
        do {
            return try query.execute()
        } catch {
            throw .queryFailed(String(describing: error))
        }
    }
}
