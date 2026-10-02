import Foundation
import Testing
@testable import ThinkingOrbsKit

struct PlaybackClockTests {
    private func date(_ seconds: Double) -> Date {
        Date(timeIntervalSinceReferenceDate: seconds)
    }

    @Test func newInstancesSharePhaseDespiteDifferentCreationTimes() {
        let first = OrbPlaybackClock(date: date(100), speed: 2, paused: false)
        let second = OrbPlaybackClock(date: date(110), speed: 2, paused: false)
        #expect(first.time(at: date(120)) == 240)
        #expect(second.time(at: date(120)) == 240)
    }

    @Test func speedChangePreservesPhaseAtModernTimestamp() {
        var clock = OrbPlaybackClock(date: date(812_000_000), speed: 1, paused: false)
        clock.update(date: date(812_000_010), speed: 1.05, paused: false)
        #expect(clock.time(at: date(812_000_010)) == 812_000_010)
        #expect(abs(clock.time(at: date(812_000_011)) - 812_000_011.05) < 1e-6)
    }

    @Test func pauseAndResumeExcludePausedDuration() {
        var clock = OrbPlaybackClock(date: date(100), speed: 1, paused: false)
        clock.update(date: date(110), speed: 1, paused: true)
        #expect(clock.time(at: date(150)) == 110)
        clock.update(date: date(150), speed: 1, paused: false)
        #expect(clock.time(at: date(151)) == 111)
    }

    @Test func zeroSpeedPreservesPhaseAndResumesAtNewSpeed() {
        var clock = OrbPlaybackClock(date: date(100), speed: 1, paused: false)
        clock.update(date: date(110), speed: 0, paused: false)
        #expect(clock.time(at: date(150)) == 110)
        clock.update(date: date(150), speed: 2, paused: false)
        #expect(clock.time(at: date(151)) == 112)
    }

    @Test func changingSpeedWhilePausedDoesNotMoveFrozenFrame() {
        var clock = OrbPlaybackClock(date: date(100), speed: 1, paused: true)
        clock.update(date: date(110), speed: 2, paused: true)
        #expect(clock.time(at: date(150)) == 100)
        clock.update(date: date(150), speed: 2, paused: false)
        #expect(clock.time(at: date(151)) == 102)
    }

    @Test func unchangedInputsDoNotResetPhase() {
        var clock = OrbPlaybackClock(date: date(100), speed: 1, paused: false)
        clock.update(date: date(110), speed: 2, paused: false)
        clock.update(date: date(120), speed: 2, paused: false)
        #expect(clock.time(at: date(125)) == 140)
    }

    @Test func extremeSpeedIsNormalizedOnInitializationAndUpdate() {
        var clock = OrbPlaybackClock(date: date(100), speed: .greatestFiniteMagnitude, paused: false)
        #expect(clock.time(at: date(101)) == 10_100)
        clock.update(date: date(101), speed: .nan, paused: false)
        #expect(clock.time(at: date(102)) == 10_101)
    }
}
