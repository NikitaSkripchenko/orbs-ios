import Foundation

// Ported from thinking-orbs src/engine/web.ts at
// de85557ca220332586d070d8788c0e1d6e877a0d under the MIT license.
func frameWeb(size: Double, time: Double, options: ModeOptions) -> OrbFrame {
    let center = size / 2
    let sphereRadius = (size / 2) * 0.8 * options["spread", default: 1]
    let project = OrbMath.projector(
        yaw: time * 0.12,
        tilt: 0.32,
        centerX: center,
        centerY: center,
        scale: sphereRadius
    )
    let radiusScale = OrbMath.radiusScale(size: size, power: options["rsPow", default: 0.6])
    let nodeCount = Int(options["nodeN", default: 30])
    let threshold = options["thr", default: 0.72]
    let nodeRadius = options["nodeR", default: 1.4]
    let nodeDepthRadius = options["nodeRDepth", default: 1.8]
    var nodes: [(Double, Double, Double)] = []

    for index in 0..<nodeCount {
        let direction = OrbMath.fibonacciDirection(index: index, count: nodeCount)
        let value = Double(index)
        let x = direction.0
            + 0.3 * (OrbMath.valueNoise(value * 0.31 + 9, time * 0.24) - 0.5) * 2
        let y = direction.1
            + 0.3 * (OrbMath.valueNoise(value * 0.53 + 27, time * 0.21) - 0.5) * 2
        let z = direction.2
            + 0.3 * (OrbMath.valueNoise(value * 0.77 + 55, time * 0.27) - 0.5) * 2
        let length = sqrt(x * x + y * y + z * z)
        nodes.append((x / length, y / length, z / length))
    }

    var lines: [OrbLine] = []
    var dots: [OrbDot] = []
    for first in 0..<nodeCount {
        for second in (first + 1)..<nodeCount {
            let deltaX = nodes[first].0 - nodes[second].0
            let deltaY = nodes[first].1 - nodes[second].1
            let deltaZ = nodes[first].2 - nodes[second].2
            let distance = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
            guard distance < threshold else { continue }
            let start = project(nodes[first].0, nodes[first].1, nodes[first].2)
            let end = project(nodes[second].0, nodes[second].1, nodes[second].2)
            let depth = ((start.2 + end.2) / 2 + 1) / 2
            lines.append(OrbLine(
                x1: start.0,
                y1: start.1,
                x2: end.0,
                y2: end.1,
                white: 0.42,
                alpha: (1 - distance / threshold) * (0.3 + 0.55 * depth),
                width: max(0.6, options["lineW", default: 0.8] * radiusScale)
            ))
        }
    }

    for index in 0..<nodeCount {
        let projected = project(nodes[index].0, nodes[index].1, nodes[index].2)
        let depth = (projected.2 + 1) / 2
        let pulse = 1 + 0.25 * sin(time * 1.4 + Double(index) * 2.7)
        dots.append(OrbDot(
            x: projected.0,
            y: projected.1,
            z: projected.2,
            radius: (nodeRadius + nodeDepthRadius * depth) * pulse * radiusScale,
            white: 0.55 - 0.45 * depth,
            alpha: 1
        ))
    }

    let signalCount = Int(options["signals", default: 5])
    for signal in 0..<signalCount {
        let signalValue = Double(signal)
        let segment = floor(time * 0.55 + signalValue * 7.31)
        let first = Int(floor(OrbMath.hash(segment, signalValue * 3.1 + 1.7) * Double(nodeCount)))
        let second = Int(floor(OrbMath.hash(segment, signalValue * 5.7 + 4.2) * Double(nodeCount)))
        guard first != second else { continue }
        let fraction = OrbMath.frac(time * 0.55 + signalValue * 7.31)
        let x = OrbMath.lerp(nodes[first].0, nodes[second].0, fraction)
        let y = OrbMath.lerp(nodes[first].1, nodes[second].1, fraction)
        let z = OrbMath.lerp(nodes[first].2, nodes[second].2, fraction)
        let length = max(1e-6, sqrt(x * x + y * y + z * z))
        let projected = project(x / length, y / length, z / length)
        let depth = (projected.2 + 1) / 2
        dots.append(OrbDot(
            x: projected.0,
            y: projected.1,
            z: projected.2,
            radius: (nodeRadius * 1.5 + nodeDepthRadius * depth) * radiusScale,
            white: 0.05,
            alpha: 0.5 + 0.5 * depth
        ))
    }

    return OrbMath.finalize(
        dots: dots,
        lines: lines,
        minimumRadius: options["rMin", default: 0.3]
    )
}
