import Foundation
import Testing
@testable import ThinkingOrbsKit

struct RendererBehaviorTests {
    @Test func refreshRateSelectsMinimumInterval() {
        #expect(OrbRenderBehavior.minimumInterval(allowsHighRefreshRate: false) == 1.0 / 60.0)
        #expect(OrbRenderBehavior.minimumInterval(allowsHighRefreshRate: true) == 1.0 / 120.0)
    }

    @Test func refreshCadencePreservesPlaybackAndSuspension() {
        let start = Date(timeIntervalSinceReferenceDate: 100)
        for (speed, paused, reduceMotion) in [(2.0, false, false), (2.0, true, false), (0.0, false, false), (2.0, false, true)] {
            let suspended = OrbRenderBehavior.isTimelinePaused(
                paused: paused, reduceMotion: reduceMotion, userSpeed: speed
            )
            let clock = OrbPlaybackClock(date: start, speed: speed, paused: suspended)
            for highRefresh in [false, true, false] {
                let interval = OrbRenderBehavior.minimumInterval(allowsHighRefreshRate: highRefresh)
                let nextTick = start.addingTimeInterval(interval)
                let expected = 100 * speed + (suspended ? 0 : interval * speed)
                #expect(abs(clock.time(at: nextTick) - expected) < 1e-10)
                #expect(clock.time(at: start.addingTimeInterval(1)) == 100 * speed + (suspended ? 0 : speed))
                if reduceMotion {
                    #expect(OrbRenderBehavior.modeTime(
                        playbackTime: clock.time(at: nextTick), reduceMotion: true, presetSpeed: 1
                    ) == OrbSpec.staticTime)
                }
            }
        }
    }

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
