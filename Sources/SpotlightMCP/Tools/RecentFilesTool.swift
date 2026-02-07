import Foundation
import MCP

/// Handles the `recent_files` tool — find recently modified files.
struct RecentFilesTool: Sendable {
    private let builder: QueryBuilder

    init(builder: QueryBuilder = QueryBuilder()) {
        self.builder = builder
    }

    func handle(_ args: ArgumentParser) throws(ToolError) -> CallTool.Result {
        let scopePath = try args.requireString("scope")
        let pagination = PaginationConfig(requested: args.optionalInt("limit"))
        let isoDate = try resolveSinceDate(args.optionalString("since"))
        let results = try executeQuery(isoDate, scopePath)
        let paginated = pagination.apply(to: results)
        return .init(content: [ResultFormatter.format(paginated)])
    }
}

extension RecentFilesTool {
    private func resolveSinceDate(_ since: String?) throws(ToolError) -> String {
        guard let since else {
            return defaultSinceISO()
        }
        try validateISO8601(since)
        return since
    }

    private func defaultSinceISO() -> String {
        let date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return ISO8601DateFormatter().string(from: date)
    }

    private func validateISO8601(_ string: String) throws(ToolError) {
        guard ISO8601DateFormatter().date(from: string) != nil else {
            throw .invalidArgument("Invalid ISO 8601 date: \(string)")
        }
    }

    private func executeQuery(
        _ isoDate: String,
        _ scopePath: String
    ) throws(ToolError) -> [SearchResult] {
        let queryString = builder.modifiedSince(isoDate)
        let scope = [URL(fileURLWithPath: scopePath)]
        let query = SpotlightQuery(queryString: queryString, scope: scope)
        do {
            return try query.execute()
        } catch {
            throw .queryFailed(String(describing: error))
        }
    }
}
