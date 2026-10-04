import Foundation

struct OrbPlaybackClock {
    private var anchorDate: Date
    private var phase: Double
    private var rate: Double

    init(date: Date, speed: Double, paused: Bool) {
        let speed = OrbEngine.normalizedSpeed(speed)
        anchorDate = date
        // New instances share a phase; later input changes preserve local continuity.
        phase = max(0, date.timeIntervalSinceReferenceDate) * speed
        rate = paused ? 0 : speed
    }

    func time(at date: Date) -> Double {
        phase + max(0, date.timeIntervalSince(anchorDate)) * rate
    }

    mutating func update(date: Date, speed: Double, paused: Bool) {
        phase = time(at: date)
        anchorDate = date
        rate = paused ? 0 : OrbEngine.normalizedSpeed(speed)
    }
}

enum OrbInk {
    static func gray(white: Double, dark: Bool) -> Double {
        let clamped = min(1, max(0, white))
        return dark ? 1 - clamped : clamped
    }
}

enum OrbRenderBehavior {
    static func minimumInterval(allowsHighRefreshRate: Bool) -> TimeInterval {
        1.0 / (allowsHighRefreshRate ? 120.0 : 60.0)
    }

    static func accessibilityLabel(custom: String?, state: OrbState) -> String {
        custom ?? state.accessibilityLabel
    }

    static func isTimelinePaused(
        paused: Bool,
        reduceMotion: Bool,
        userSpeed: Double
    ) -> Bool {
        paused || reduceMotion || OrbEngine.normalizedSpeed(userSpeed) == 0
    }

    static func modeTime(
        playbackTime: Double,
        reduceMotion: Bool,
        presetSpeed: Double
    ) -> Double {
        if reduceMotion { return OrbSpec.staticTime }
        return playbackTime * presetSpeed
    }
}

#if os(iOS)
import SwiftUI

/// A deterministic, accessible SwiftUI thinking animation.
///
/// Use an orb as a decorative status indicator while nearby interface text explains
/// the operation in more detail.
public struct ThinkingOrb: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @State private var clock: OrbPlaybackClock

    private let state: OrbState
    private let size: OrbSize
    private let theme: OrbTheme
    private let speed: Double
    private let paused: Bool
    private let reduceMotionOverride: Bool?
    private let customAccessibilityLabel: String?
    private let allowsHighRefreshRate: Bool

    /// Creates a thinking orb.
    ///
    /// - Parameters:
    ///   - state: The semantic activity and animation mode.
    ///   - size: One of the two tuned upstream sizes.
    ///   - theme: Automatic or explicit monochrome appearance.
    ///   - speed: A multiplier for the preset speed. Nonfinite values use `1` and
    ///     finite values clamp to `0...100`.
    ///   - paused: Whether to freeze the current phase. Resuming continues from that phase.
    ///   - reduceMotionOverride: A testing and demo override. Pass `nil` in production
    ///     to respect the system Reduce Motion setting.
    ///   - accessibilityLabel: A custom VoiceOver label, or `nil` for the state's default.
    ///   - allowsHighRefreshRate: Allows up to 120 fps on supported displays. The system
    ///     controls actual cadence; consuming iPhone apps must enable
    ///     `CADisableMinimumFrameDurationOnPhone` in their Info.plist. Defaults to `false`.
    public init(
        state: OrbState = .working,
        size: OrbSize = .points64,
        theme: OrbTheme = .automatic,
        speed: Double = 1,
        paused: Bool = false,
        reduceMotionOverride: Bool? = nil,
        accessibilityLabel: String? = nil,
        allowsHighRefreshRate: Bool = false
    ) {
        self.state = state
        self.size = size
        self.theme = theme
        self.speed = speed
        self.paused = paused
        self.reduceMotionOverride = reduceMotionOverride
        self.customAccessibilityLabel = accessibilityLabel
        self.allowsHighRefreshRate = allowsHighRefreshRate
        _clock = State(initialValue: OrbPlaybackClock(date: Date(), speed: speed, paused: paused))
    }

    public var body: some View {
        // Read State in body so reanchoring also redraws a suspended TimelineView.
        let playbackClock = clock
        let resolved = OrbSpec.resolve(state: state, size: size)
        let effectiveReduceMotion = reduceMotionOverride ?? reduceMotion
        let timelinePaused = OrbRenderBehavior.isTimelinePaused(
            paused: paused,
            reduceMotion: effectiveReduceMotion,
            userSpeed: speed
        )
        TimelineView(.animation(
            minimumInterval: OrbRenderBehavior.minimumInterval(allowsHighRefreshRate: allowsHighRefreshRate),
            paused: timelinePaused
        )) { timeline in
            Canvas { context, _ in
                let modeTime = OrbRenderBehavior.modeTime(
                    playbackTime: playbackClock.time(at: timeline.date),
                    reduceMotion: effectiveReduceMotion,
                    presetSpeed: resolved.speed
                )
                let frame = OrbEngine.frame(
                    resolved: resolved,
                    size: size,
                    modeTime: modeTime
                )
                let dark = resolvedDarkTheme

                for line in frame.lines {
                    var path = Path()
                    path.move(to: CGPoint(x: CGFloat(line.x1), y: CGFloat(line.y1)))
                    path.addLine(to: CGPoint(x: CGFloat(line.x2), y: CGFloat(line.y2)))
                    context.stroke(
                        path,
                        with: .color(color(white: line.white, alpha: line.alpha, dark: dark)),
                        lineWidth: CGFloat(line.width)
                    )
                }

                for dot in frame.dots {
                    let rectangle = CGRect(
                        x: CGFloat(dot.x - dot.radius),
                        y: CGFloat(dot.y - dot.radius),
                        width: CGFloat(dot.radius * 2),
                        height: CGFloat(dot.radius * 2)
                    )
                    context.fill(
                        Path(ellipseIn: rectangle),
                        with: .color(color(white: dot.white, alpha: dot.alpha, dark: dark))
                    )
                }
            }
        }
        .onAppear {
            clock.update(date: Date(), speed: speed, paused: timelinePaused)
        }
        .onChange(of: OrbEngine.normalizedSpeed(speed)) { newSpeed in
            clock.update(date: Date(), speed: newSpeed, paused: timelinePaused)
        }
        .onChange(of: timelinePaused) { isPaused in
            clock.update(date: Date(), speed: speed, paused: isPaused)
        }
        .frame(width: CGFloat(size.rawValue), height: CGFloat(size.rawValue))
        .accessibilityElement()
        .accessibilityLabel(OrbRenderBehavior.accessibilityLabel(
            custom: customAccessibilityLabel,
            state: state
        ))
        .accessibilityAddTraits(.isImage)
    }

    private var resolvedDarkTheme: Bool {
        switch theme {
        case .automatic: colorScheme == .dark
        case .light: false
        case .dark: true
        }
    }

    private func color(white: Double, alpha: Double, dark: Bool) -> Color {
        Color(.sRGB, white: OrbInk.gray(white: white, dark: dark), opacity: alpha)
    }
}
#endif
