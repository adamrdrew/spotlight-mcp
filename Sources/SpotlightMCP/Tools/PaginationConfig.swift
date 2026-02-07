/// Pagination configuration for search result limits.
struct PaginationConfig: Sendable {
    static let defaultLimit = 100
    static let maxLimit = 1000

    let limit: Int

    init(requested: Int?) {
        let raw = requested ?? Self.defaultLimit
        self.limit = Self.clamp(raw)
    }

    func apply<T>(to results: [T]) -> [T] {
        Array(results.prefix(limit))
    }

    private static func clamp(_ value: Int) -> Int {
        min(max(value, 1), maxLimit)
    }
}
