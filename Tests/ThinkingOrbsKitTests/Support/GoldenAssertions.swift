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

        for pair in zip(actual.dots, actual.dots.dropFirst()) {
            #expect(pair.0.z <= pair.1.z + tolerance)
        }

        let expectedDots = stride(from: 0, to: expected.dots.count, by: 6).map { offset in
            OrbDot(
                x: expected.dots[offset],
                y: expected.dots[offset + 1],
                z: expected.dots[offset + 2],
                radius: expected.dots[offset + 3],
                white: expected.dots[offset + 4],
                alpha: expected.dots[offset + 5]
            )
        }
        var unmatched = actual.dots
        for expectedDot in expectedDots {
            let expectedValues = [
                expectedDot.x,
                expectedDot.y,
                expectedDot.z,
                expectedDot.radius,
                expectedDot.white,
                expectedDot.alpha
            ]
            let match = unmatched.firstIndex { dot in
                let values = [dot.x, dot.y, dot.z, dot.radius, dot.white, dot.alpha]
                return zip(values, expectedValues).allSatisfy {
                    abs($0.0 - $0.1) <= tolerance
                }
            }
            #expect(match != nil)
            if let match { unmatched.remove(at: match) }
        }
        #expect(unmatched.isEmpty)

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
