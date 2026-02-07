import Foundation
import MCP

/// Handles the `search` tool — natural language text search with explicit scope.
struct SearchTool: Sendable {
    private let builder: QueryBuilder

    init(builder: QueryBuilder = QueryBuilder()) {
        self.builder = builder
    }

    func handle(_ args: ArgumentParser) throws(ToolError) -> CallTool.Result {
        let queryText = try args.requireString("query")
        let scopePath = try args.requireString("scope")
        let pagination = PaginationConfig(requested: args.optionalInt("limit"))
        let results = try executeSearch(queryText, scopePath)
        let paginated = pagination.apply(to: results)
        return .init(content: [ResultFormatter.format(paginated)])
    }
}

extension SearchTool {
    private func executeSearch(
        _ text: String,
        _ scopePath: String
    ) throws(ToolError) -> [SearchResult] {
        let predicate = builder.naturalText(text)
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
