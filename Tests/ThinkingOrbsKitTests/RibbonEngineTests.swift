import Testing
@testable import ThinkingOrbsKit

struct RibbonEngineTests {
    @Test func composingMatchesGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .composing) {
            frameRibbon(size: $0, time: $1, options: $2)
        }
    }

    @Test func breathingMatchesGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .breathing) {
            frameRibbon(size: $0, time: $1, options: $2)
        }
    }
}
