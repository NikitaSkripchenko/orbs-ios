import Foundation

// Ported from thinking-orbs src/engine/morph.ts at
// de85557ca220332586d070d8788c0e1d6e877a0d under the MIT license.
private typealias MorphPath = @Sendable (Double) -> (Double, Double)

private func smoothEase(_ value: Double) -> Double {
    value * value * (3 - 2 * value)
}

private func polygonPath(_ vertices: [(Double, Double)]) -> MorphPath {
    let lengths = vertices.indices.map { index in
        let start = vertices[index]
        let end = vertices[(index + 1) % vertices.count]
        return hypot(end.0 - start.0, end.1 - start.1)
    }
    let total = lengths.reduce(0, +)
    return { fraction in
        var target = fraction * total
        var segment = 0
        while segment < lengths.count - 1 && target > lengths[segment] {
            target -= lengths[segment]
            segment += 1
        }
        let start = vertices[segment]
        let end = vertices[(segment + 1) % vertices.count]
        let local = lengths[segment] == 0 ? 0 : min(1, target / lengths[segment])
        return (
            start.0 + (end.0 - start.0) * local,
            start.1 + (end.1 - start.1) * local
        )
    }
}

private let circlePath: MorphPath = { fraction in
    let angle = -.pi / 2 + fraction * 2 * .pi
    return (cos(angle) * 0.24, sin(angle) * 0.24)
}

private let trianglePath: MorphPath = polygonPath([
    (0, -0.26),
    (0.24, 0.16),
    (-0.24, 0.16)
])

private let squarePath: MorphPath = polygonPath([
    (0, -0.2),
    (0.2, -0.2),
    (0.2, 0.2),
    (-0.2, 0.2),
    (-0.2, -0.2)
])

func frameMorph(size: Double, time: Double, options: ModeOptions) -> OrbFrame {
    let paths: [MorphPath] = [circlePath, trianglePath, squarePath]
    let segmentDuration = OrbSpec.morphHold + OrbSpec.morphDuration
    let cycleTime = time.truncatingRemainder(dividingBy: segmentDuration * Double(paths.count))
    let pathIndex = Int(floor(cycleTime / segmentDuration))
    let localTime = cycleTime - Double(pathIndex) * segmentDuration
    let morphAmount = localTime > OrbSpec.morphHold
        ? smoothEase((localTime - OrbSpec.morphHold) / OrbSpec.morphDuration)
        : 0
    let spread = options["spread", default: 1]
    let sampleCount = 160
    let firstPath = paths[pathIndex]
    let secondPath = paths[(pathIndex + 1) % paths.count]
    var points: [(Double, Double)] = []
    for index in 0..<sampleCount {
        let fraction = Double(index) / Double(sampleCount)
        let first = firstPath(fraction)
        let second = secondPath(fraction)
        points.append((
            (first.0 + (second.0 - first.0) * morphAmount) * spread,
            (first.1 + (second.1 - first.1) * morphAmount) * spread
        ))
    }

    let lengths = points.indices.map { index in
        let start = points[index]
        let end = points[(index + 1) % points.count]
        return hypot(end.0 - start.0, end.1 - start.1)
    }
    let totalLength = lengths.reduce(0, +)
    let dotCount = max(6, Int((34 * options["iconD", default: 1]).rounded(.toNearestOrAwayFromZero)))
    let dotRadius = options["rDot", default: 0.021] * 1.35 * spread
    let pulse = 1 + 0.02 * sin(localTime * 3.1)
    let center = size / 2
    var dots: [OrbDot] = []
    var segment = 0
    var accumulated = 0.0

    for index in 0..<dotCount {
        let target = Double(index) / Double(dotCount) * totalLength
        while segment < sampleCount - 1 && accumulated + lengths[segment] < target {
            accumulated += lengths[segment]
            segment += 1
        }
        let start = points[segment]
        let end = points[(segment + 1) % points.count]
        let local = lengths[segment] == 0
            ? 0
            : min(1, (target - accumulated) / lengths[segment])
        let x = (start.0 + (end.0 - start.0) * local) * pulse
        let y = (start.1 + (end.1 - start.1) * local) * pulse
        dots.append(OrbDot(
            x: center + x * size,
            y: center + y * size,
            z: 0,
            radius: max(0.35, dotRadius * size),
            white: 0.1,
            alpha: 1
        ))
    }

    return OrbMath.finalize(dots: dots, lines: [], minimumRadius: options["rMin", default: 0.25])
}
