import Foundation

// Ported from thinking-orbs src/engine/ribbon.ts at
// de85557ca220332586d070d8788c0e1d6e877a0d under the MIT license.
func frameRibbon(size: Double, time: Double, options: ModeOptions) -> OrbFrame {
    let center = size / 2
    let sphereRadius = (size / 2) * 0.78
    let spin = options["spin", default: 1]
    let cameraTilt = 0.3
    let project = OrbMath.projector(
        yaw: time * 0.1 * spin,
        tilt: cameraTilt,
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

    let faceOn = options["faceOn", default: 0] != 0
    let yaw = time * 0.24 * spin
    let tilt = faceOn ? -cameraTilt : 0.55 + 0.3 * sin(time * 0.18) * spin
    let basisUX = cos(yaw)
    let basisUY = 0.0
    let basisUZ = sin(yaw)
    let basisVX = -basisUZ * sin(tilt)
    let basisVY = cos(tilt)
    let basisVZ = basisUX * sin(tilt)
    let normalX = basisUY * basisVZ - basisUZ * basisVY
    let normalY = basisUZ * basisVX - basisUX * basisVZ
    let normalZ = basisUX * basisVY - basisUY * basisVX
    let wobbleMultiplier = options["wobMul", default: 1]
    let wobbleAmplitude = 0.23 * wobbleMultiplier
    let baseRadius = faceOn
        ? sphereRadius / (1 + 0.85 * wobbleAmplitude)
        : sphereRadius
    let baseLaneCount = options["lanes", default: 5]
    let segmentCount = Int(options["segs", default: 88])
    let laneCount = max(1, Int((baseLaneCount * options["bandMul", default: 1]).rounded(.toNearestOrAwayFromZero)))

    for lane in 0..<laneCount {
        let offset = (Double(lane) - Double(laneCount - 1) / 2) * 0.075
        let edge = abs(Double(lane) - Double(laneCount - 1) / 2)
            / max(1, Double(laneCount - 1) / 2)
        for segment in 0..<segmentCount {
            let angle = (Double(segment) / Double(segmentCount)) * 2 * .pi
            let wobble = (
                0.16 * sin(angle * 3 - time * 1.7 + Double(lane) * 0.22)
                    + 0.07 * sin(angle * 5 + time * 1.1)
            ) * wobbleMultiplier
            let radial = faceOn ? 1 + wobble : 1
            let normalOffset = faceOn ? offset : offset + wobble
            let x = basisUX * cos(angle) + basisVX * sin(angle) + normalX * normalOffset
            let y = basisUY * cos(angle) + basisVY * sin(angle) + normalY * normalOffset
            let z = basisUZ * cos(angle) + basisVZ * sin(angle) + normalZ * normalOffset
            let length = sqrt(x * x + y * y + z * z)
            let radius = baseRadius * radial
            let projected = project(
                (x / length) * radius,
                (y / length) * radius,
                (z / length) * radius
            )
            let depth = (projected.2 / sphereRadius + 1) / 2
            dots.append(OrbDot(
                x: projected.0,
                y: projected.1,
                z: projected.2,
                radius: (
                    options["rBase", default: 1.1]
                        + options["rDepth", default: 1.7] * depth
                ) * (1 - 0.25 * edge) * radiusScale,
                white: 0.52 - 0.44 * depth + 0.18 * edge,
                alpha: 0.4 + 0.6 * depth
            ))
        }
    }

    return OrbMath.finalize(
        dots: dots,
        lines: [],
        minimumRadius: options["rMin", default: 0.3]
    )
}
