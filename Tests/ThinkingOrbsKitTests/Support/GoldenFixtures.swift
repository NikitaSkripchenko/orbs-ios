import Foundation
import Testing

struct GoldenFile: Decodable {
    let specVersion: String
    let tolerance: Double
    let resolved: [String: GoldenResolved]
    let cases: [GoldenCase]
}

struct GoldenResolved: Decodable {
    let mode: String
    let speed: Double
    let opts: [String: Double]
}

struct GoldenCase: Decodable {
    let key: String
    let state: String
    let size: Int
    let mode: String
    let time: Double
    let dotCount: Int
    let lineCount: Int
    let dots: [Double]
    let lines: [Double]

    private enum CodingKeys: String, CodingKey {
        case key, state, size, mode, dotCount, lineCount, dots, lines
        case time = "t"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try values.decode(String.self, forKey: .key)
        state = try values.decode(String.self, forKey: .state)
        size = try values.decode(Int.self, forKey: .size)
        mode = try values.decode(String.self, forKey: .mode)
        time = try values.decode(Double.self, forKey: .time)
        dotCount = try values.decode(Int.self, forKey: .dotCount)
        lineCount = try values.decode(Int.self, forKey: .lineCount)
        dots = try values.decode([Double].self, forKey: .dots)
        lines = try values.decode([Double].self, forKey: .lines)

        guard dots.count == dotCount * 6, lines.count == lineCount * 7 else {
            throw CocoaError(.coderReadCorrupt)
        }
    }
}

enum GoldenFixtures {
    static func load() throws -> GoldenFile {
        let url = try #require(Bundle.module.url(forResource: "orbs-golden", withExtension: "json"))
        return try JSONDecoder().decode(GoldenFile.self, from: Data(contentsOf: url))
    }
}
