import Testing
@testable import ThinkingOrbsKit

struct GoldenParityTests {
    @Test func everyPinnedGoldenCaseMatches() throws {
        let golden = try GoldenFixtures.load()
        #expect(golden.cases.count == 72)
        for expected in golden.cases {
            let state = try #require(OrbState(rawValue: expected.state))
            let size = try #require(OrbSize(rawValue: Double(expected.size)))
            let frame = OrbEngine.frame(state: state, size: size, modeTime: expected.time)
            try GoldenFixtures.assert(frame, equals: expected, tolerance: golden.tolerance)
        }
    }
}
