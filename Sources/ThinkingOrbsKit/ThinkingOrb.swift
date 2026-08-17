import SwiftUI

enum OrbInk {
    static func gray(white: Double, dark: Bool) -> Double {
        let clamped = min(1, max(0, white))
        return dark ? 1 - clamped : clamped
    }
}

enum OrbRenderBehavior {
    static func modeTime(
        date: Date,
        reduceMotion: Bool,
        presetSpeed: Double,
        userSpeed: Double
    ) -> Double {
        if reduceMotion { return OrbSpec.staticTime }
        return date.timeIntervalSinceReferenceDate
            * presetSpeed
            * OrbEngine.normalizedSpeed(userSpeed)
    }
}

public struct ThinkingOrb: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    private let state: OrbState
    private let size: OrbSize
    private let theme: OrbTheme
    private let speed: Double
    private let paused: Bool
    private let customAccessibilityLabel: String?

    public init(
        state: OrbState = .working,
        size: OrbSize = .points64,
        theme: OrbTheme = .automatic,
        speed: Double = 1,
        paused: Bool = false,
        accessibilityLabel: String? = nil
    ) {
        self.state = state
        self.size = size
        self.theme = theme
        self.speed = speed
        self.paused = paused
        self.customAccessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        let resolved = OrbSpec.resolve(state: state, size: size)
        TimelineView(.animation(
            minimumInterval: 1.0 / 60.0,
            paused: paused || reduceMotion
        )) { timeline in
            Canvas { context, _ in
                let modeTime = OrbRenderBehavior.modeTime(
                    date: timeline.date,
                    reduceMotion: reduceMotion,
                    presetSpeed: resolved.speed,
                    userSpeed: speed
                )
                let frame = OrbEngine.frame(state: state, size: size, modeTime: modeTime)
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
        .frame(width: CGFloat(size.rawValue), height: CGFloat(size.rawValue))
        .accessibilityElement()
        .accessibilityLabel(customAccessibilityLabel ?? state.accessibilityLabel)
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
