// Generated from thinking-orbs spec 1.0.0 at commit de85557ca220332586d070d8788c0e1d6e877a0d.
// Do not edit by hand; run Scripts/generate-orb-spec.swift.

enum OrbSpec {
    static let staticTime = 0.6
    static let morphHold = 1.4
    static let morphDuration = 0.9
    static let rubikSlotDuration = 0.42
    static let rubikRest = 1.2

    static let stateModes: [OrbState: OrbMode] = [
        .breathing: .ring,
        .composing: .ribbon,
        .connecting: .web,
        .listening: .wave,
        .searching: .globe,
        .shaping: .morph,
        .solving: .rubik,
        .weaving: .braid,
        .working: .orbits
    ]

    static let stateLabels: [OrbState: String] = [
        .breathing: "Thinking…",
        .composing: "Composing…",
        .connecting: "Connecting…",
        .listening: "Listening…",
        .searching: "Searching…",
        .shaping: "Shaping…",
        .solving: "Solving…",
        .weaving: "Weaving…",
        .working: "Working…"
    ]

    static let baseProfiles: [OrbMode: ModeOptions] = [
        .braid: ModeOptions(values: [
            "ghostN": 150,
            "rBase": 1.2,
            "rDepth": 1.8,
            "rMin": 0.3,
            "rsPow": 0.6,
            "strandN": 52,
            "turns": 3
        ]),
        .globe: ModeOptions(values: [
            "inkFar": 0.62,
            "inkSpan": 0.54,
            "latRings": 17,
            "lonDensity": 44,
            "rBase": 0.6,
            "rBoost": 1,
            "rDepth": 1.7,
            "rMin": 0.3,
            "rsPow": 0.6
        ]),
        .morph: ModeOptions(values: [
            "iconD": 1,
            "rDot": 0.021,
            "rMin": 0.25
        ]),
        .orbits: ModeOptions(values: [
            "ghostA": 0.5,
            "ghostN": 40,
            "ghostR": 0.9,
            "orbitN": 12,
            "partR": 1.2,
            "partRDepth": 1.6,
            "particles": 3,
            "rMin": 0.3,
            "rsPow": 0.6
        ]),
        .ribbon: ModeOptions(values: [
            "ghostN": 150,
            "lanes": 5,
            "rBase": 1.1,
            "rDepth": 1.7,
            "rMin": 0.3,
            "rsPow": 0.6,
            "segs": 88
        ]),
        .ring: ModeOptions(values: [
            "faceOn": 1,
            "ghostN": 0,
            "lanes": 5,
            "rBase": 1.1,
            "rDepth": 1.7,
            "rMin": 0.3,
            "rsPow": 0.6,
            "segs": 88
        ]),
        .rubik: ModeOptions(values: [
            "inkFar": 0.62,
            "inkSpan": 0.54,
            "latRings": 15,
            "lonDensity": 40,
            "moveCount": 14,
            "rActive": 0.3,
            "rBase": 0.6,
            "rDepth": 1.7,
            "rMin": 0.3,
            "rsPow": 0.6
        ]),
        .wave: ModeOptions(values: [
            "lonDensity": 40,
            "rBase": 0.6,
            "rDepth": 1.7,
            "rMin": 0.3,
            "rings": 15,
            "rsPow": 0.6
        ]),
        .web: ModeOptions(values: [
            "lineW": 0.8,
            "nodeN": 30,
            "nodeR": 1.4,
            "nodeRDepth": 1.8,
            "rMin": 0.3,
            "rsPow": 0.6,
            "signals": 5,
            "thr": 0.72
        ])
    ]

    static let presets: [OrbMode: [OrbSize: OrbPreset]] = [
        .braid: [
            .points20: OrbPreset(
                speed: 2.75,
                count: 0.1125,
                size: 1.36,
                extra: [:]
            ),
            .points64: OrbPreset(
                speed: 1.625,
                count: 0.5,
                size: 1,
                extra: [:]
            )
        ],
        .globe: [
            .points20: OrbPreset(
                speed: 2.665,
                count: 0.105,
                size: 1.75,
                extra: [
                "dimBase": 0.45,
                "scanMul": 4.335
            ]
            ),
            .points64: OrbPreset(
                speed: 2.015,
                count: 0.42,
                size: 1.15,
                extra: [
                "dimBase": 0.45,
                "scanMul": 4.08
            ]
            )
        ],
        .morph: [
            .points20: OrbPreset(
                speed: 2.08,
                count: 0.53,
                size: 1.011,
                extra: [
                "spread": 1.45
            ]
            ),
            .points64: OrbPreset(
                speed: 2.405,
                count: 0.702,
                size: 0.395,
                extra: [
                "spread": 1.45
            ]
            )
        ],
        .orbits: [
            .points20: OrbPreset(
                speed: 3.9,
                count: 0.238,
                size: 2.4,
                extra: [:]
            ),
            .points64: OrbPreset(
                speed: 1.885,
                count: 1,
                size: 1,
                extra: [:]
            )
        ],
        .ribbon: [
            .points20: OrbPreset(
                speed: 3.12,
                count: 0.051,
                size: 1.073,
                extra: [
                "bandMul": 4.94,
                "spin": 0,
                "wobMul": 1
            ]
            ),
            .points64: OrbPreset(
                speed: 2.34,
                count: 0.25,
                size: 0.85,
                extra: [
                "bandMul": 3.9,
                "spin": 0,
                "wobMul": 1
            ]
            )
        ],
        .ring: [
            .points20: OrbPreset(
                speed: 3.78,
                count: 0.028,
                size: 1.622,
                extra: [
                "bandMul": 3.968,
                "spin": 0,
                "wobMul": 0.5649999999999999
            ]
            ),
            .points64: OrbPreset(
                speed: 3.24,
                count: 0.25,
                size: 0.956,
                extra: [
                "bandMul": 3.627,
                "spin": 0,
                "wobMul": 0.368
            ]
            )
        ],
        .rubik: [
            .points20: OrbPreset(
                speed: 1.95,
                count: 0.08799999999999999,
                size: 1.9,
                extra: [:]
            ),
            .points64: OrbPreset(
                speed: 1.82,
                count: 0.35,
                size: 1.05,
                extra: [:]
            )
        ],
        .wave: [
            .points20: OrbPreset(
                speed: 3.998,
                count: 0.105,
                size: 1.6,
                extra: [:]
            ),
            .points64: OrbPreset(
                speed: 4.388,
                count: 0.341,
                size: 1,
                extra: [:]
            )
        ],
        .web: [
            .points20: OrbPreset(
                speed: 6.63,
                count: 0.25,
                size: 1.52,
                extra: [:]
            ),
            .points64: OrbPreset(
                speed: 3.315,
                count: 1.35,
                size: 0.95,
                extra: [:]
            )
        ]
    ]

    private static let countPairs = [
        OptionPair(first: "latRings", second: "lonDensity"),
        OptionPair(first: "rings", second: "lonDensity"),
        OptionPair(first: "lanes", second: "segs")
    ]
    private static let countKeys = ["orbitN", "ghostN", "nodeN", "strandN", "signals"]
    private static let iconDensityKeys = ["iconD"]
    private static let radiusKeys = ["rBase", "rDepth", "rActive", "rDot", "ghostR", "partR", "partRDepth", "nodeR", "nodeRDepth"]

    static func resolve(state: OrbState, size: OrbSize) -> ResolvedPreset {
        guard let mode = stateModes[state],
              let base = baseProfiles[mode],
              let preset = presets[mode]?[size] else {
            preconditionFailure("Missing generated preset")
        }

        var options = base
        if preset.count != 1 { scaleCounts(&options, by: preset.count) }
        if preset.size != 1 { scaleRadii(&options, by: preset.size) }
        options.values.merge(preset.extra) { _, extra in extra }
        return ResolvedPreset(mode: mode, speed: preset.speed, options: options)
    }

    private static func scaleCounts(_ options: inout ModeOptions, by scale: Double) {
        var completed = Set<String>()
        let root = scale.squareRoot()
        for pair in countPairs {
            guard let first = options.values[pair.first],
                  let second = options.values[pair.second],
                  !completed.contains(pair.first),
                  !completed.contains(pair.second) else { continue }
            options.values[pair.first] = max(2, (first * root).rounded(.toNearestOrAwayFromZero))
            options.values[pair.second] = max(2, (second * root).rounded(.toNearestOrAwayFromZero))
            completed.insert(pair.first)
            completed.insert(pair.second)
        }
        for key in countKeys {
            guard let value = options.values[key], value != 0, !completed.contains(key) else { continue }
            options.values[key] = max(1, (value * scale).rounded(.toNearestOrAwayFromZero))
        }
        for key in iconDensityKeys {
            guard let value = options.values[key] else { continue }
            options.values[key] = max(0.02, value * scale)
        }
    }

    private static func scaleRadii(_ options: inout ModeOptions, by scale: Double) {
        for key in radiusKeys where options.values[key] != nil {
            options.values[key]! *= scale
        }
        options.values["rSizeMul"] = (options.values["rSizeMul"] ?? 1) * scale
    }
}