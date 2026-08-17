import Foundation

// Ported from thinking-orbs src/engine/braid.ts at
// de85557ca220332586d070d8788c0e1d6e877a0d under the MIT license.
func frameBraid(size: Double, time: Double, options: ModeOptions) -> OrbFrame {
    let center = size / 2
    let sphereRadius = (size / 2) * 0.76
    let project = OrbMath.projector(
        yaw: time * 0.4,
        tilt: 0.3,
        centerX: center,
        centerY: center,
        scale: 1
    )
    let radiusScale = OrbMath.radiusScale(size: size, power: options["rsPow", default: 0.6])
    var dots: [OrbDot] = []
    let ghostCount = Int(options["ghostN", default: 150])
    for index in 0..<ghostCount {
        let direction = OrbMath.fibonacciDirection(index: index, count: ghostCount)
        let projected = project(
            direction.0 * sphereRadius,
            direction.1 * sphereRadius,
            direction.2 * sphereRadius
        )
        let depth = (projected.2 / sphereRadius + 1) / 2
        dots.append(OrbDot(
            x: projected.0,
            y: projected.1,
            z: projected.2,
            radius: 0.8 * radiusScale,
            white: 0.78,
            alpha: 0.1 + 0.22 * depth
        ))
    }

    let strandCount = Int(options["strandN", default: 52])
    let turns = options["turns", default: 3]
    for strand in 0..<3 {
        let phase = (Double(strand) / 3) * 2 * .pi
        for index in 0..<strandCount {
            let vertical = (
                OrbMath.frac(Double(index) / Double(strandCount) + time * 0.045) * 2 - 1
            ) * 0.96
            let surface = sqrt(max(0, 1 - vertical * vertical))
            let endFade = min(1, (1 - abs(vertical)) / 0.1)
            let angle = vertical * .pi * turns + phase
            let weave = 1 + 0.075 * sin(
                vertical * .pi * turns * 2 + phase * 2 + time * 0.8
            )
            let radial = surface * sphereRadius * weave
            let projected = project(
                cos(angle) * radial,
                vertical * sphereRadius * weave,
                sin(angle) * radial
            )
            let depth = (projected.2 / sphereRadius + 1) / 2
            dots.append(OrbDot(
                x: projected.0,
                y: projected.1,
                z: projected.2,
                radius: (
                    options["rBase", default: 1.2]
                        + options["rDepth", default: 1.8] * depth
                ) * radiusScale,
                white: 0.55 - 0.45 * depth,
                alpha: endFade * (0.45 + 0.55 * depth)
            ))
        }
    }

    return OrbMath.finalize(
        dots: dots,
        lines: [],
        minimumRadius: options["rMin", default: 0.3]
    )
}
