import Testing
@testable import ThinkingOrbsKit

struct WebEngineTests {
    @Test func connectingMatchesDotsAndLinesAtBothSizes() throws {
        try GoldenFixtures.assertCases(for: .connecting) { size, time, options in
            frameWeb(size: size, time: time, options: options)
        }
    }
}
