import Foundation
import Testing
@testable import ThinkingOrbsKit

struct RendererBehaviorTests {
    @Test func resolvesThemeAndMirrorsInk() {
        #expect(OrbInk.gray(white: 0.2, dark: false) == 0.2)
        #expect(OrbInk.gray(white: 0.2, dark: true) == 0.8)
        #expect(OrbInk.gray(white: 2, dark: false) == 1)
        #expect(OrbInk.gray(white: -1, dark: true) == 1)
    }

    @Test func reduceMotionUsesPinnedStaticModeTime() {
        #expect(
            OrbRenderBehavior.modeTime(
                date: .distantFuture,
                reduceMotion: true,
                presetSpeed: 9,
                userSpeed: 2
            ) == 0.6
        )
    }

    @Test func normalizesInvalidSpeed() {
        #expect(OrbEngine.normalizedSpeed(.nan) == 1)
        #expect(OrbEngine.normalizedSpeed(-2) == 0)
        #expect(OrbEngine.normalizedSpeed(1.5) == 1.5)
    }

    @Test func runningModeUsesPresetAndUserSpeed() {
        let date = Date(timeIntervalSinceReferenceDate: 2)
        #expect(
            OrbRenderBehavior.modeTime(
                date: date,
                reduceMotion: false,
                presetSpeed: 3,
                userSpeed: 2
            ) == 12
        )
    }
}
