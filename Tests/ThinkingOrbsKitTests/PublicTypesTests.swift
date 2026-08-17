import Testing
@testable import ThinkingOrbsKit

struct PublicTypesTests {
    @Test func exposesAllUpstreamStatesInStableOrder() {
        #expect(OrbState.allCases.map(\.rawValue) == [
            "working", "searching", "solving", "listening", "connecting",
            "weaving", "composing", "breathing", "shaping"
        ])
    }

    @Test func exposesOnlyTheTwoTunedSizes() {
        #expect(OrbSize.allCases.map(\.rawValue) == [20, 64])
    }

    @Test func exposesAutomaticAndExplicitThemes() {
        #expect(OrbTheme.allCases.map(\.rawValue) == ["automatic", "light", "dark"])
    }

    @Test func suppliesUpstreamAccessibilityLabels() {
        let expected: [(OrbState, String)] = [
            (.working, "Working…"), (.searching, "Searching…"),
            (.solving, "Solving…"), (.listening, "Listening…"),
            (.connecting, "Connecting…"), (.weaving, "Weaving…"),
            (.composing, "Composing…"), (.breathing, "Thinking…"),
            (.shaping, "Shaping…")
        ]
        #expect(expected.allSatisfy { $0.0.accessibilityLabel == $0.1 })
    }
}
