import Foundation

enum GeneratorError: Error {
    case usage
    case invalidRoot
    case missing(String)
}

guard CommandLine.arguments.count == 3 else {
    throw GeneratorError.usage
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
let object = try JSONSerialization.jsonObject(with: Data(contentsOf: inputURL))
guard let root = object as? [String: Any] else {
    throw GeneratorError.invalidRoot
}

func dictionary(_ value: Any?, _ name: String) throws -> [String: Any] {
    guard let value = value as? [String: Any] else {
        throw GeneratorError.missing(name)
    }
    return value
}

func strings(_ value: Any?, _ name: String) throws -> [String] {
    guard let value = value as? [String] else {
        throw GeneratorError.missing(name)
    }
    return value
}

func number(_ value: Any?, _ name: String) throws -> String {
    guard let value = value as? NSNumber else {
        throw GeneratorError.missing(name)
    }
    return value.stringValue
}

func quoted(_ value: String) -> String {
    "\"\(value.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
}

func optionsExpression(_ value: [String: Any], indent: String) throws -> String {
    let rows = try value.keys.sorted().map { key in
        "\(indent)    \(quoted(key)): \(try number(value[key], key))"
    }
    return "ModeOptions(values: [\n\(rows.joined(separator: ",\n"))\n\(indent)])"
}

let enums = try dictionary(root["enums"], "enums")
let modes = try strings(enums["modes"], "enums.modes")
let stateToMode = try dictionary(root["stateToMode"], "stateToMode")
let labels = try dictionary(root["labels"], "labels")
let baseProfiles = try dictionary(root["baseProfiles"], "baseProfiles")
let presets = try dictionary(root["presets"], "presets")
let scaling = try dictionary(root["scaling"], "scaling")
let timing = try dictionary(root["timing"], "timing")
let morphTiming = try dictionary(timing["morph"], "timing.morph")
let rubikTiming = try dictionary(timing["rubik"], "timing.rubik")

guard Set(modes) == Set(["orbits", "globe", "rubik", "wave", "web", "braid", "ribbon", "ring", "morph"]) else {
    throw GeneratorError.missing("known modes")
}
let stateRows = try stateToMode.keys.sorted().map { state in
    guard let mode = stateToMode[state] as? String else { throw GeneratorError.missing(state) }
    return "        .\(state): .\(mode)"
}.joined(separator: ",\n")
let labelRows = try labels.keys.sorted().map { state in
    guard let label = labels[state] as? String else { throw GeneratorError.missing(state) }
    return "        .\(state): \(quoted(label))"
}.joined(separator: ",\n")
let baseRows = try baseProfiles.keys.sorted().map { mode in
    let options = try dictionary(baseProfiles[mode], "baseProfiles.\(mode)")
    return "        .\(mode): \(try optionsExpression(options, indent: "        "))"
}.joined(separator: ",\n")
let presetRows = try presets.keys.sorted().map { mode in
    let sizes = try dictionary(presets[mode], "presets.\(mode)")
    let sizeRows = try sizes.keys.sorted().map { size in
        let preset = try dictionary(sizes[size], "presets.\(mode).\(size)")
        let extra = (preset["extra"] as? [String: Any]) ?? [:]
        let extraRows = try extra.keys.sorted().map { key in
            "                \(quoted(key)): \(try number(extra[key], key))"
        }.joined(separator: ",\n")
        let extraExpression = extra.isEmpty
            ? "[:]"
            : "[\n\(extraRows)\n            ]"
        let sizeCase = size == "20" ? "points20" : "points64"
        return """
            .\(sizeCase): OrbPreset(
                speed: \(try number(preset["speed"], "speed")),
                count: \(try number(preset["count"], "count")),
                size: \(try number(preset["size"], "size")),
                extra: \(extraExpression)
            )
"""
    }.joined(separator: ",\n")
    return """
        .\(mode): [
\(sizeRows)
        ]
"""
}.joined(separator: ",\n")

guard let rawPairs = scaling["countPairs"] as? [[String]],
      let countKeys = scaling["countKeys"] as? [String],
      let iconDensityKeys = scaling["iconDensityKeys"] as? [String],
      let radiusKeys = scaling["radiusKeys"] as? [String] else {
    throw GeneratorError.missing("scaling keys")
}
let pairRows = rawPairs.map { "        OptionPair(first: \(quoted($0[0])), second: \(quoted($0[1])))" }.joined(separator: ",\n")
let countKeyRows = countKeys.map(quoted).joined(separator: ", ")
let iconKeyRows = iconDensityKeys.map(quoted).joined(separator: ", ")
let radiusKeyRows = radiusKeys.map(quoted).joined(separator: ", ")

let output = """
// Generated from thinking-orbs spec 1.0.0 at commit de85557ca220332586d070d8788c0e1d6e877a0d.
// Do not edit by hand; run Scripts/generate-orb-spec.swift.

enum OrbSpec {
    static let staticTime = 0.6
    static let morphHold = \(try number(morphTiming["hold"], "morph hold"))
    static let morphDuration = \(try number(morphTiming["morph"], "morph duration"))
    static let rubikSlotDuration = \(try number(rubikTiming["slotDuration"], "rubik slot"))
    static let rubikRest = \(try number(rubikTiming["rest"], "rubik rest"))

    static let stateModes: [OrbState: OrbMode] = [
\(stateRows)
    ]

    static let stateLabels: [OrbState: String] = [
\(labelRows)
    ]

    static let baseProfiles: [OrbMode: ModeOptions] = [
\(baseRows)
    ]

    static let presets: [OrbMode: [OrbSize: OrbPreset]] = [
\(presetRows)
    ]

    private static let countPairs = [
\(pairRows)
    ]
    private static let countKeys = [\(countKeyRows)]
    private static let iconDensityKeys = [\(iconKeyRows)]
    private static let radiusKeys = [\(radiusKeyRows)]

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
"""

try FileManager.default.createDirectory(
    at: outputURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
)
try output.write(to: outputURL, atomically: true, encoding: .utf8)
