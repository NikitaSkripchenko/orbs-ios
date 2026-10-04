# Changelog

All notable changes to ThinkingOrbsKit are documented here.

The project follows [Semantic Versioning](https://semver.org/) after its first tagged release.

## Unreleased

### Fixed

- Changing speed preserves animation phase; pause and zero speed resume from the frozen phase.
- Finite speed is limited to `0...100` to prevent geometry crashes at extreme values.
- The demo respects system Reduce Motion when its preview override is off.
- Added clock sequence and rendered UI regressions for playback and system accessibility settings.

### Added

- Opt-in `allowsHighRefreshRate` for up to 120 fps, with a shared demo toggle and ProMotion configuration guidance.

- iOS consumer-module tests for the complete public initializer surface.
- Automated package, iOS, UI, performance-budget, generated-source, and secret checks.
- DocC API documentation and contributor guidance.

### Changed

- Zero and negative normalized speeds now pause timeline scheduling to avoid rendering
  frames that cannot advance.
- The SwiftUI renderer reuses its resolved preset instead of resolving it twice per frame.

## 0.1.0 - Unreleased

- Ported all nine upstream thinking-orb modes to native Swift.
- Added the 20-point and 64-point tuned sizes.
- Added automatic, light, and dark themes; speed and pause controls; Reduce Motion;
  shared-clock timing; and accessibility labels.
- Added pinned golden-vector parity for upstream commit
  `de85557ca220332586d070d8788c0e1d6e877a0d`.
- Added the native iPhone and iPad demo application.
