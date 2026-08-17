import Testing
@testable import ThinkingOrbsKit

struct OrbSpecTests {
    @Test func resolvesEveryStateAndSizeFromGoldenMetadata() throws {
        let golden = try GoldenFixtures.load()

        for state in OrbState.allCases {
            for size in OrbSize.allCases {
                let key = "\(state.rawValue)-\(Int(size.rawValue))"
                let expected = try #require(golden.resolved[key])
                let actual = OrbSpec.resolve(state: state, size: size)

                #expect(actual.mode.rawValue == expected.mode)
                #expect(abs(actual.speed - expected.speed) <= golden.tolerance)
                #expect(Set(actual.options.values.keys) == Set(expected.opts.keys))
                for option in expected.opts {
                    let value = try #require(actual.options.values[option.key])
                    #expect(abs(value - option.value) <= golden.tolerance)
                }
            }
        }
    }
}
