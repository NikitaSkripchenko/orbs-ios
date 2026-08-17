struct OrbDot: Equatable, Sendable {
    let x: Double
    let y: Double
    let z: Double
    let radius: Double
    let white: Double
    let alpha: Double
}

struct OrbLine: Equatable, Sendable {
    let x1: Double
    let y1: Double
    let x2: Double
    let y2: Double
    let white: Double
    let alpha: Double
    let width: Double
}

struct OrbFrame: Equatable, Sendable {
    let dots: [OrbDot]
    let lines: [OrbLine]

    static let empty = OrbFrame(dots: [], lines: [])
}

typealias OrbProjector = @Sendable (Double, Double, Double) -> (Double, Double, Double)
typealias ModeFrame = @Sendable (Double, Double, ModeOptions) -> OrbFrame
