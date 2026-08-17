import Testing
@testable import ThinkingOrbsKit

struct LatticeEngineTests {
    @Test func searchingMatchesGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .searching) {
            frameGlobe(size: $0, time: $1, options: $2)
        }
    }

    @Test func solvingMatchesGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .solving) {
            frameRubik(size: $0, time: $1, options: $2)
        }
    }

    @Test func listeningMatchesGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .listening) {
            frameWave(size: $0, time: $1, options: $2)
        }
    }
}
