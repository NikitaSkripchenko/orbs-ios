import Testing
@testable import ThinkingOrbsKit

struct MorphEngineTests {
    @Test func shapingMatchesHoldAndTransitionGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .shaping) { size, time, options in
            frameMorph(size: size, time: time, options: options)
        }
    }
}
