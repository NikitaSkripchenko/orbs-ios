enum OrbMode: String, Codable, CaseIterable, Sendable {
    case orbits
    case globe
    case rubik
    case wave
    case web
    case braid
    case ribbon
    case ring
    case morph
}

struct ModeOptions: Equatable, Sendable {
    var values: [String: Double]

    subscript(_ key: String, default fallback: Double) -> Double {
        values[key] ?? fallback
    }
}

struct OrbPreset: Equatable, Sendable {
    let speed: Double
    let count: Double
    let size: Double
    let extra: [String: Double]
}

struct ResolvedPreset: Equatable, Sendable {
    let mode: OrbMode
    let speed: Double
    let options: ModeOptions
}

struct OptionPair: Sendable {
    let first: String
    let second: String
}
