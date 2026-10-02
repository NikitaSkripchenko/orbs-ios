import Foundation
import Testing
@testable import ThinkingOrbsKit

struct RendererBehaviorTests {
    @Test func extremeFiniteSpeedProducesRenderableFrames() throws {
        for state in OrbState.allCases {
            for size in OrbSize.allCases {
                let resolved = OrbSpec.resolve(state: state, size: size)
                let date = Date(timeIntervalSinceReferenceDate: 812_000_000)
                let clock = OrbPlaybackClock(date: date, speed: .greatestFiniteMagnitude, paused: false)
                let time = OrbRenderBehavior.modeTime(
                    playbackTime: clock.time(at: date),
                    reduceMotion: false,
                    presetSpeed: resolved.speed
                )
                try #require(time.isFinite)
                let frame = OrbEngine.frame(resolved: resolved, size: size, modeTime: time)
                #expect(!frame.dots.isEmpty)
                #expect(frame.dots.allSatisfy {
                    [$0.x, $0.y, $0.z, $0.radius, $0.white, $0.alpha].allSatisfy(\.isFinite)
                })
            }
        }
    }

    @Test func resolvesThemeAndMirrorsInk() {
        #expect(OrbInk.gray(white: 0.2, dark: false) == 0.2)
        #expect(OrbInk.gray(white: 0.2, dark: true) == 0.8)
        #expect(OrbInk.gray(white: 2, dark: false) == 1)
        #expect(OrbInk.gray(white: -1, dark: true) == 1)
    }

    @Test func resolvesDefaultAndCustomAccessibilityLabels() {
        #expect(OrbRenderBehavior.accessibilityLabel(custom: nil, state: .searching) == "Searching…")
        #expect(OrbRenderBehavior.accessibilityLabel(
            custom: "Finding similar photos",
            state: .searching
        ) == "Finding similar photos")
    }

    @Test func reduceMotionUsesPinnedStaticModeTime() {
        #expect(
            OrbRenderBehavior.modeTime(
                    playbackTime: 812_000_000,
                    reduceMotion: true,
                    presetSpeed: 9
            ) == 0.6
        )
    }

    @Test func normalizesInvalidSpeed() {
        #expect(OrbEngine.normalizedSpeed(.nan) == 1)
        #expect(OrbEngine.normalizedSpeed(.infinity) == 1)
        #expect(OrbEngine.normalizedSpeed(-2) == 0)
        #expect(OrbEngine.normalizedSpeed(1.5) == 1.5)
    }

    @Test func pausesTimelineWhenFramesCannotAdvance() {
        #expect(OrbRenderBehavior.isTimelinePaused(
            paused: false,
            reduceMotion: false,
            userSpeed: 0
        ))
        #expect(OrbRenderBehavior.isTimelinePaused(
            paused: false,
            reduceMotion: false,
            userSpeed: -1
        ))
        #expect(OrbRenderBehavior.isTimelinePaused(
            paused: true,
            reduceMotion: false,
            userSpeed: 1
        ))
        #expect(OrbRenderBehavior.isTimelinePaused(
            paused: false,
            reduceMotion: true,
            userSpeed: 1
        ))
        #expect(!OrbRenderBehavior.isTimelinePaused(
            paused: false,
            reduceMotion: false,
            userSpeed: .nan
        ))
        #expect(!OrbRenderBehavior.isTimelinePaused(
            paused: false,
            reduceMotion: false,
            userSpeed: 1
        ))
    }

    @Test func runningModeUsesPresetAndUserSpeed() {
        let date = Date(timeIntervalSinceReferenceDate: 2)
        let clock = OrbPlaybackClock(date: date, speed: 2, paused: false)
        #expect(
            OrbRenderBehavior.modeTime(
                playbackTime: clock.time(at: date),
                reduceMotion: false,
                presetSpeed: 3
            ) == 12
        )
    }

    @Test func resolvedPresetFrameMatchesPublicDispatchPath() {
        let resolved = OrbSpec.resolve(state: .working, size: .points64)
        let expected = OrbEngine.frame(state: .working, size: .points64, modeTime: 1.25)
        let actual = OrbEngine.frame(
            resolved: resolved,
            size: .points64,
            modeTime: 1.25
        )

        #expect(actual == expected)
    }
}
