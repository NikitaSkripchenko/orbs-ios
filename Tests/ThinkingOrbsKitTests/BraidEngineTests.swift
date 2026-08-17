import Testing
@testable import ThinkingOrbsKit

struct BraidEngineTests {
    @Test func weavingMatchesGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .weaving) { size, time, options in
            frameBraid(size: size, time: time, options: options)
        }
    }
}
