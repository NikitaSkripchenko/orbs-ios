# ThinkingOrbsKit architecture decisions

## ADR-001: Native Swift geometry

- Status: Accepted
- Date: 2026-08-17

Port the upstream deterministic TypeScript engine to pure Swift. Do not embed JavaScript or WebKit.

## ADR-002: Pinned spec and golden vectors

- Status: Accepted
- Date: 2026-08-17

Vendor the upstream spec and golden fixtures from commit `de85557ca220332586d070d8788c0e1d6e877a0d`. Require numeric parity within `1e-4`.

## ADR-003: Compile-time preset data

- Status: Accepted
- Date: 2026-08-17

Generate and commit Swift preset constants during repository maintenance. Package consumers do not run generators or parse JSON at runtime.

## ADR-004: SwiftUI Canvas renderer

- Status: Accepted
- Date: 2026-08-17

Render finished line and dot lists with `TimelineView` and `Canvas`. Keep rendering separate from engine geometry.

## ADR-005: iOS-only version 0.1

- Status: Accepted
- Date: 2026-08-17

Support iOS 15 and later for version 0.1. Validate macOS separately before adding it as a supported platform.

## ADR-006: Native checked-in demo project

- Status: Accepted
- Date: 2026-08-17

Maintain `ThinkingOrbsDemo.xcodeproj` directly. Do not introduce XcodeGen or another project generator.

## ADR-007: Equal-depth golden comparison

- Status: Accepted
- Date: 2026-08-17

Swift and JavaScript standard-library math can produce different sub-tolerance signed-zero ordering for dots at exactly equal depth. The engine still emits dots monotonically far-to-near. Golden tests compare dot geometry as a unique multiset within `1e-4` and separately assert monotonic depth order; line order remains strict.

## ADR-008: Dedicated iOS consumer test target

- Status: Accepted
- Date: 2026-08-18

Keep deterministic geometry tests in the Swift Package test target and verify the iOS-only public SwiftUI surface from the checked-in `ThinkingOrbsKitIOSTests` Xcode target. The target imports `ThinkingOrbsKit` without `@testable`, so public API availability is tested from a consumer's perspective without claiming macOS support.

## ADR-009: Continuous playback after control changes

- Status: Accepted
- Date: 2026-10-02

New orbs initialize from the common reference date. Each SwiftUI view retains a pure playback clock with an anchor date, accumulated phase, and normalized rate. Reanchor at speed and suspension changes so speed, pause, zero speed, and Reduce Motion do not retroactively rescale elapsed time. Resume from the frozen animated phase. This favors continuity over re-synchronizing independently controlled instances. State/size changes still select the corresponding preset and may change geometry immediately. Finite speed is bounded to `0...100`; nonfinite speed uses `1`. Geometry and pinned upstream vectors are unchanged.

## ADR-010: Opt-in higher refresh schedule

- Status: Accepted
- Date: 2026-10-04

Append `allowsHighRefreshRate: Bool = false` to the public initializer. Select a
pure minimum interval of 1/60 or 1/120 second without changing playback state or
view identity. Share the demo preference across both tabs and adaptive settings.
Enable `CADisableMinimumFrameDurationOnPhone` in the demo; consumers configure
it in their own app. Actual 120 fps remains subject to the display and system.
