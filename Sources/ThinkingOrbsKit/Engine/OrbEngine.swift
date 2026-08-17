import Foundation

enum OrbEngine {
    static func normalizedSpeed(_ speed: Double) -> Double {
        guard speed.isFinite else { return 1 }
        return max(0, speed)
    }

    static func frame(
        state: OrbState,
        size: OrbSize,
        modeTime: Double
    ) -> OrbFrame {
        let resolved = OrbSpec.resolve(state: state, size: size)
        switch resolved.mode {
        case .orbits:
            return frameOrbits(size: size.rawValue, time: modeTime, options: resolved.options)
        case .globe:
            return frameGlobe(size: size.rawValue, time: modeTime, options: resolved.options)
        case .rubik:
            return frameRubik(size: size.rawValue, time: modeTime, options: resolved.options)
        case .wave:
            return frameWave(size: size.rawValue, time: modeTime, options: resolved.options)
        case .web:
            return frameWeb(size: size.rawValue, time: modeTime, options: resolved.options)
        case .braid:
            return frameBraid(size: size.rawValue, time: modeTime, options: resolved.options)
        case .ribbon, .ring:
            return frameRibbon(size: size.rawValue, time: modeTime, options: resolved.options)
        case .morph:
            return frameMorph(size: size.rawValue, time: modeTime, options: resolved.options)
        }
    }
}
