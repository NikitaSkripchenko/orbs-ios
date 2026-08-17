import Testing
@testable import ThinkingOrbsKit

struct OrbMathTests {
    @Test func reproducesPinnedDeterministicPrimitives() {
        #expect(abs(OrbMath.hash(0, 1.7) - 0.9343791858918848) < 1e-12)
        #expect(abs(OrbMath.frac(-1.25) - 0.75) < 1e-12)
        #expect(abs(OrbMath.angleDelta(.pi * 1.5, 0) + .pi / 2) < 1e-12)
        #expect(abs(OrbMath.radiusScale(size: 64, power: 0.6) - 0.3957630383738824) < 1e-12)
    }

    @Test func finalizationCullsClampsAndSorts() {
        let frame = OrbMath.finalize(
            dots: [
                .init(x: 0, y: 0, z: 2, radius: 0.1, white: 0.5, alpha: 1),
                .init(x: 0, y: 0, z: -2, radius: 1, white: 0.5, alpha: 1),
                .init(x: 0, y: 0, z: 0, radius: 1, white: 0.5, alpha: 0.01)
            ],
            lines: [
                .init(x1: 0, y1: 0, x2: 1, y2: 1, white: 0.5, alpha: 0.01, width: 1),
                .init(x1: 0, y1: 0, x2: 1, y2: 1, white: 0.5, alpha: 1, width: 1)
            ],
            minimumRadius: 0.3
        )

        #expect(frame.dots.map(\.z) == [-2, 2])
        #expect(frame.dots[1].radius == 0.3)
        #expect(frame.lines.count == 1)
    }
}
