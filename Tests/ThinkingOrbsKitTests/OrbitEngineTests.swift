import Testing
@testable import ThinkingOrbsKit

struct OrbitEngineTests {
    @Test func workingMatchesAllEightGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .working) { size, time, options in
            frameOrbits(size: size, time: time, options: options)
        }
    }
}
