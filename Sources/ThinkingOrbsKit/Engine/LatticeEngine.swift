import Foundation

// Ported from thinking-orbs src/engine/lattice.ts at
// de85557ca220332586d070d8788c0e1d6e877a0d under the MIT license.
private struct LatticeMove {
    let axis: Int
    let lowerBound: Double
    let upperBound: Double
    let angle: Double
}

private struct SolveCycle {
    let amounts: [Double]
    let active: Int
}

private func solveCycle(time: Double, count: Int) -> SolveCycle {
    let slotDuration = OrbSpec.rubikSlotDuration
    let rest = OrbSpec.rubikRest
    let cycle = 2 * Double(count) * slotDuration + rest
    let cycleTime = time.truncatingRemainder(dividingBy: cycle)
    var amounts = Array(repeating: 0.0, count: count)
    var active = -1
    if cycleTime < 2 * Double(count) * slotDuration {
        let slot = Int(floor(cycleTime / slotDuration))
        let progress = (cycleTime - Double(slot) * slotDuration) / slotDuration
        let clamped = min(1, progress / 0.7)
        let eased = 1 - pow(1 - clamped, 3)
        if slot < count {
            if slot > 0 {
                for index in 0..<slot { amounts[index] = 1 }
            }
            amounts[slot] = eased
            active = slot
        } else {
            let undo = 2 * count - 1 - slot
            if undo > 0 {
                for index in 0..<undo { amounts[index] = 1 }
            }
            amounts[undo] = 1 - eased
            active = undo
        }
    }
    return SolveCycle(amounts: amounts, active: active)
}

private func applyMoves(
    point: (Double, Double, Double),
    moves: [LatticeMove],
    cycle: SolveCycle
) -> (Double, Double, Double, Bool) {
    var x = point.0
    var y = point.1
    var z = point.2
    var isActive = false
    for index in moves.indices {
        guard cycle.amounts[index] > 0 else { continue }
        let move = moves[index]
        let coordinate = move.axis == 0 ? x : move.axis == 1 ? y : z
        guard coordinate >= move.lowerBound, coordinate < move.upperBound else { continue }
        if index == cycle.active { isActive = true }
        let angle = move.angle * cycle.amounts[index]
        let cosine = cos(angle)
        let sine = sin(angle)
        if move.axis == 0 {
            let nextY = y * cosine - z * sine
            z = y * sine + z * cosine
            y = nextY
        } else if move.axis == 1 {
            let nextX = x * cosine + z * sine
            z = -x * sine + z * cosine
            x = nextX
        } else {
            let nextX = x * cosine - y * sine
            y = x * sine + y * cosine
            x = nextX
        }
    }
    return (x, y, z, isActive)
}

private func makeMoves(count: Int) -> [LatticeMove] {
    (0..<count).map { index in
        let value = Double(index)
        let axis = min(2, Int(floor(OrbMath.hash(value, 2.3) * 3)))
        let lowerBound = -1 + 0.5 * Double(min(3, Int(floor(OrbMath.hash(value, 5.9) * 4))))
        let direction = OrbMath.hash(value, 7.7) < 0.5 ? 1.0 : -1.0
        return LatticeMove(
            axis: axis,
            lowerBound: lowerBound,
            upperBound: lowerBound + 0.5,
            angle: direction * .pi / 2
        )
    }
}

func frameGlobe(size: Double, time: Double, options: ModeOptions) -> OrbFrame {
    let spin = 0.5
    let center = size / 2
    let sphereRadius = (size / 2) * 0.82
    let tilt = 0.4 + 0.06 * sin(time * 0.35)
    let project = OrbMath.projector(
        yaw: time * spin,
        tilt: tilt,
        centerX: center,
        centerY: center,
        scale: sphereRadius
    )
    let scan = time * (spin + (1.7 - spin) * options["scanMul", default: 1])
    let radiusScale = OrbMath.radiusScale(size: size, power: options["rsPow", default: 0.6])
    let dimBase = options["dimBase", default: 1]
    let latitudeRings = Int(options["latRings", default: 17])
    let longitudeDensity = Int(options["lonDensity", default: 44])
    var dots: [OrbDot] = []

    for latitudeIndex in 0...latitudeRings {
        let latitude = -.pi / 2 + (Double(latitudeIndex) / Double(latitudeRings)) * .pi
        let cosineLatitude = cos(latitude)
        let sineLatitude = sin(latitude)
        let longitudeCount = max(1, Int((abs(cosineLatitude) * Double(longitudeDensity)).rounded(.toNearestOrAwayFromZero)))
        for longitudeIndex in 0..<longitudeCount {
            let longitude = (Double(longitudeIndex) / Double(longitudeCount)) * 2 * .pi
            let projected = project(
                cosineLatitude * cos(longitude),
                sineLatitude,
                cosineLatitude * sin(longitude)
            )
            let depth = (projected.2 + 1) / 2
            let delta = OrbMath.angleDelta(longitude + time * spin, scan)
            let boost = exp(-(delta * delta) / 0.18) * max(0, projected.2)
            dots.append(OrbDot(
                x: projected.0,
                y: projected.1,
                z: projected.2,
                radius: (
                    options["rBase", default: 0.6]
                        + options["rDepth", default: 1.7] * depth
                        + options["rBoost", default: 1] * boost
                ) * radiusScale,
                white: options["inkFar", default: 0.62]
                    - options["inkSpan", default: 0.54] * depth,
                alpha: dimBase + (1 - dimBase) * min(1, boost)
            ))
        }
    }
    return OrbMath.finalize(dots: dots, lines: [], minimumRadius: options["rMin", default: 0.3])
}

func frameRubik(size: Double, time: Double, options: ModeOptions) -> OrbFrame {
    let center = size / 2
    let sphereRadius = (size / 2) * 0.82
    let project = OrbMath.projector(
        yaw: time * 0.55,
        tilt: 0.35 + 0.1 * sin(time * 0.9),
        centerX: center,
        centerY: center,
        scale: sphereRadius
    )
    let radiusScale = OrbMath.radiusScale(size: size, power: options["rsPow", default: 0.6])
    let moveCount = Int(options["moveCount", default: 14])
    let moves = makeMoves(count: moveCount)
    let cycle = solveCycle(time: time, count: moveCount)
    let latitudeRings = Int(options["latRings", default: 15])
    let longitudeDensity = Int(options["lonDensity", default: 40])
    var dots: [OrbDot] = []

    for latitudeIndex in 0...latitudeRings {
        let latitude = -.pi / 2 + (Double(latitudeIndex) / Double(latitudeRings)) * .pi
        let cosineLatitude = cos(latitude)
        let sineLatitude = sin(latitude)
        let longitudeCount = max(1, Int((abs(cosineLatitude) * Double(longitudeDensity)).rounded(.toNearestOrAwayFromZero)))
        for longitudeIndex in 0..<longitudeCount {
            let longitude = (Double(longitudeIndex) / Double(longitudeCount)) * 2 * .pi
            let moved = applyMoves(
                point: (cosineLatitude * cos(longitude), sineLatitude, cosineLatitude * sin(longitude)),
                moves: moves,
                cycle: cycle
            )
            let projected = project(moved.0, moved.1, moved.2)
            let depth = (projected.2 + 1) / 2
            dots.append(OrbDot(
                x: projected.0,
                y: projected.1,
                z: projected.2,
                radius: (
                    options["rBase", default: 0.6]
                        + options["rDepth", default: 1.7] * depth
                        + (moved.3 ? options["rActive", default: 0.3] : 0)
                ) * radiusScale,
                white: options["inkFar", default: 0.62]
                    - options["inkSpan", default: 0.54] * depth
                    - (moved.3 ? 0.14 : 0),
                alpha: 1
            ))
        }
    }
    return OrbMath.finalize(dots: dots, lines: [], minimumRadius: options["rMin", default: 0.3])
}

func frameWave(size: Double, time: Double, options: ModeOptions) -> OrbFrame {
    let center = size / 2
    let sphereRadius = (size / 2) * 0.874
    let project = OrbMath.projector(
        yaw: time * 0.18,
        tilt: 0.38,
        centerX: center,
        centerY: center,
        scale: 1
    )
    let radiusScale = OrbMath.radiusScale(size: size, power: options["rsPow", default: 0.6])
    let ringCount = Int(options["rings", default: 15])
    let longitudeDensity = Int(options["lonDensity", default: 40])
    var dots: [OrbDot] = []

    for ringIndex in 0...ringCount {
        let latitude = -.pi / 2 + (Double(ringIndex) / Double(ringCount)) * .pi
        let cosineLatitude = cos(latitude)
        let sineLatitude = sin(latitude)
        let wave = 0.62 * sin(time * 2.1 - Double(ringIndex) * 0.52)
            + 0.38 * sin(time * 1.27 + Double(ringIndex) * 0.83)
        let ringRadius = sphereRadius * (0.88 + 0.105 * wave)
        let longitudeCount = max(1, Int((abs(cosineLatitude) * Double(longitudeDensity)).rounded(.toNearestOrAwayFromZero)))
        for longitudeIndex in 0..<longitudeCount {
            let longitude = (Double(longitudeIndex) / Double(longitudeCount)) * 2 * .pi
            let projected = project(
                cosineLatitude * cos(longitude) * ringRadius,
                sineLatitude * ringRadius,
                cosineLatitude * sin(longitude) * ringRadius
            )
            let depth = (projected.2 / sphereRadius + 1) / 2
            let crest = max(0, wave)
            dots.append(OrbDot(
                x: projected.0,
                y: projected.1,
                z: projected.2,
                radius: (
                    options["rBase", default: 0.6]
                        + options["rDepth", default: 1.7] * depth
                ) * (1 + 0.4 * crest) * radiusScale,
                white: 0.66 - 0.56 * depth - 0.1 * crest,
                alpha: 1
            ))
        }
    }
    return OrbMath.finalize(dots: dots, lines: [], minimumRadius: options["rMin", default: 0.3])
}
