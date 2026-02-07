import Testing
@testable import SpotlightMCP

@Suite("PaginationConfig Tests")
struct PaginationConfigTests {
    @Test("default limit is 100")
    func defaultLimitIs100() {
        let config = PaginationConfig(requested: nil)
        #expect(config.limit == 100)
    }

    @Test("respects requested limit")
    func respectsRequestedLimit() {
        let config = PaginationConfig(requested: 50)
        #expect(config.limit == 50)
    }

    @Test("clamps to max 1000")
    func clampsToMax1000() {
        let config = PaginationConfig(requested: 5000)
        #expect(config.limit == 1000)
    }

    @Test("clamps to min 1")
    func clampsToMin1() {
        let config = PaginationConfig(requested: 0)
        #expect(config.limit == 1)
    }

    @Test("apply truncates results")
    func applyTruncatesResults() {
        let config = PaginationConfig(requested: 2)
        let input = [1, 2, 3, 4, 5]
        let result = config.apply(to: input)
        #expect(result == [1, 2])
    }

    @Test("apply preserves results within limit")
    func applyPreservesResultsWithinLimit() {
        let config = PaginationConfig(requested: 10)
        let input = [1, 2, 3]
        let result = config.apply(to: input)
        #expect(result == [1, 2, 3])
    }
}
