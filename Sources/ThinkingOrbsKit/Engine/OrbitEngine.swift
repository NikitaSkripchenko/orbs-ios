import Foundation

// Ported from thinking-orbs src/engine/orbits.ts at
// de85557ca220332586d070d8788c0e1d6e877a0d under the MIT license.
func frameOrbits(size: Double, time: Double, options: ModeOptions) -> OrbFrame {
    let centerX = size / 2
    let centerY = size / 2
    let sphereRadius = (size / 2) * 0.82
    let project = OrbMath.projector(
        yaw: time * 0.12,
        tilt: 0.3,
        centerX: centerX,
        centerY: centerY,
        scale: 1
    )
    let radiusScale = OrbMath.radiusScale(
        size: size,
        power: options["rsPow", default: 0.6]
    )
    let orbitCount = Int(options["orbitN", default: 12])
    let ghostCount = Int(options["ghostN", default: 40])
    let particleCount = Int(options["particles", default: 3])
    var dots: [OrbDot] = []

    for orbit in 0..<orbitCount {
        let h1 = OrbMath.hash(Double(orbit), 1.7)
        let h2 = OrbMath.hash(Double(orbit), 5.2)
        let h3 = OrbMath.hash(Double(orbit), 8.9)
        let orbitRadius = sphereRadius * (0.45 + 0.52 * h1)
        let theta = h1 * 2 * .pi
        let phi = acos(2 * h2 - 1)
        let normalX = sin(phi) * cos(theta)
        let normalY = cos(phi)
        let normalZ = sin(phi) * sin(theta)
        var basisUX = -normalY
        var basisUY = normalX
        let basisUZ = 0.0
        let basisULength = max(1e-6, sqrt(basisUX * basisUX + basisUY * basisUY))
        basisUX /= basisULength
        basisUY /= basisULength
        let basisVX = normalY * basisUZ - normalZ * basisUY
        let basisVY = normalZ * basisUX - normalX * basisUZ
        let basisVZ = normalX * basisUY - normalY * basisUX
        let speed = (0.25 + 0.55 * h3) * (h3 > 0.5 ? 1 : -1)

        for index in 0..<ghostCount {
            let angle = (Double(index) / Double(ghostCount)) * 2 * .pi
            let projected = project(
                (basisUX * cos(angle) + basisVX * sin(angle)) * orbitRadius,
                (basisUY * cos(angle) + basisVY * sin(angle)) * orbitRadius,
                (basisUZ * cos(angle) + basisVZ * sin(angle)) * orbitRadius
            )
            let depth = (projected.2 / orbitRadius + 1) / 2
            dots.append(OrbDot(
                x: projected.0,
                y: projected.1,
                z: projected.2,
                radius: options["ghostR", default: 0.9] * radiusScale,
                white: 0.72,
                alpha: options["ghostA", default: 0.5] * (0.4 + 0.6 * depth)
            ))
        }

        for particle in 0..<particleCount {
            let angle = time * speed
                + (Double(particle) / Double(particleCount)) * 2 * .pi
                + h2 * 6
            let projected = project(
                (basisUX * cos(angle) + basisVX * sin(angle)) * orbitRadius,
                (basisUY * cos(angle) + basisVY * sin(angle)) * orbitRadius,
                (basisUZ * cos(angle) + basisVZ * sin(angle)) * orbitRadius
            )
            let depth = (projected.2 / orbitRadius + 1) / 2
            dots.append(OrbDot(
                x: projected.0,
                y: projected.1,
                z: projected.2,
                radius: (
                    options["partR", default: 1.2]
                        + options["partRDepth", default: 1.6] * depth
                ) * radiusScale,
                white: 0.3 - 0.22 * depth,
                alpha: 1
            ))
        }
    }

    return OrbMath.finalize(
        dots: dots,
        lines: [],
        minimumRadius: options["rMin", default: 0.3]
    )
}
