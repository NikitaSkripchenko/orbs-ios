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
