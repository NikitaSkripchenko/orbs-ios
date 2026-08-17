import Testing
@testable import ThinkingOrbsKit

extension GoldenFixtures {
    static func assert(
        _ actual: OrbFrame,
        equals expected: GoldenCase,
        tolerance: Double
    ) throws {
        #expect(actual.dots.count == expected.dotCount)
        #expect(actual.lines.count == expected.lineCount)
        guard actual.dots.count == expected.dotCount,
              actual.lines.count == expected.lineCount else {
            return
        }

        for (index, dot) in actual.dots.enumerated() {
            let offset = index * 6
            let values = [dot.x, dot.y, dot.z, dot.radius, dot.white, dot.alpha]
            for component in 0..<6 {
                #expect(abs(values[component] - expected.dots[offset + component]) <= tolerance)
            }
        }

        for (index, line) in actual.lines.enumerated() {
            let offset = index * 7
            let values = [line.x1, line.y1, line.x2, line.y2, line.white, line.alpha, line.width]
            for component in 0..<7 {
                #expect(abs(values[component] - expected.lines[offset + component]) <= tolerance)
            }
        }
    }

    static func assertCases(
        for state: OrbState,
        frame: (Double, Double, ModeOptions) -> OrbFrame
    ) throws {
        let golden = try load()
        let cases = golden.cases.filter { $0.state == state.rawValue }
        #expect(cases.count == 8)

        for expected in cases {
            let size = try #require(OrbSize(rawValue: Double(expected.size)))
            let resolved = OrbSpec.resolve(state: state, size: size)
            let actual = frame(size.rawValue, expected.time, resolved.options)
            try assert(actual, equals: expected, tolerance: golden.tolerance)
        }
    }
}
