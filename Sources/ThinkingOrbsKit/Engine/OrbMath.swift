import Foundation

// Ported from thinking-orbs src/engine/core.ts at
// de85557ca220332586d070d8788c0e1d6e877a0d under the MIT license.
enum OrbMath {
    static func lerp(_ start: Double, _ end: Double, _ fraction: Double) -> Double {
        start + (end - start) * fraction
    }

    static func frac(_ value: Double) -> Double {
        value - floor(value)
    }

    static func valueNoise(_ x: Double, _ y: Double) -> Double {
        let xi = floor(x)
        let yi = floor(y)
        var fx = x - xi
        var fy = y - yi
        fx = fx * fx * (3 - 2 * fx)
        fy = fy * fy * (3 - 2 * fy)
        let a = hash(xi, yi)
        let b = hash(xi + 1, yi)
        let c = hash(xi, yi + 1)
        let d = hash(xi + 1, yi + 1)
        return a + (b - a) * fx + (c - a) * fy + (a - b - c + d) * fx * fy
    }

    static func hash(_ first: Double, _ second: Double) -> Double {
        let value = sin(first * 12.9898 + second * 78.233) * 43_758.5453
        return value - floor(value)
    }

    static func fibonacciDirection(index: Int, count: Int) -> (Double, Double, Double) {
        let golden = Double.pi * (3 - sqrt(5))
        let y = 1 - (2 * (Double(index) + 0.5)) / Double(count)
        let radial = sqrt(1 - y * y)
        let angle = Double(index) * golden
        return (radial * cos(angle), y, radial * sin(angle))
    }

    static func angleDelta(_ first: Double, _ second: Double) -> Double {
        atan2(sin(first - second), cos(first - second))
    }

    static func projector(
        yaw: Double,
        tilt: Double,
        centerX: Double,
        centerY: Double,
        scale: Double
    ) -> OrbProjector {
        let sinTilt = sin(tilt)
        let cosTilt = cos(tilt)
        let sinYaw = sin(yaw)
        let cosYaw = cos(yaw)
        return { x, y, z in
            let x1 = x * cosYaw + z * sinYaw
            let z1 = -x * sinYaw + z * cosYaw
            let y1 = y * cosTilt - z1 * sinTilt
            let z2 = y * sinTilt + z1 * cosTilt
            return (centerX + x1 * scale, centerY - y1 * scale, z2)
        }
    }

    static func finalize(
        dots: [OrbDot],
        lines: [OrbLine],
        minimumRadius: Double = 0.3
    ) -> OrbFrame {
        let visible = dots.enumerated().compactMap { index, dot -> (Int, OrbDot)? in
            guard dot.alpha >= 0.02 else { return nil }
            return (
                index,
                OrbDot(
                    x: dot.x,
                    y: dot.y,
                    z: dot.z,
                    radius: max(minimumRadius, dot.radius),
                    white: dot.white,
                    alpha: dot.alpha
                )
            )
        }
        .sorted { left, right in
            left.1.z == right.1.z ? left.0 < right.0 : left.1.z < right.1.z
        }
        .map(\.1)

        return OrbFrame(
            dots: visible,
            lines: lines.filter { $0.alpha >= 0.02 }
        )
    }

    static func radiusScale(size: Double, power: Double) -> Double {
        pow(size / 300, power)
    }
}
