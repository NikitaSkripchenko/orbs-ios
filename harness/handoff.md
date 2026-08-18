# ThinkingOrbsKit handoff

## Current state

- Version: 0.1.0
- Phase: iOS package and demo implementation complete
- Branch: `feature/full-animation-port`
- Platform: iOS 15+
- macOS: deferred in `TODO.md`; not claimed by version 0.1
- Upstream commit: `de85557ca220332586d070d8788c0e1d6e877a0d`
- Upstream package/spec: `0.3.1` / `1.0.0`

## Implemented

- Nine native deterministic animation engines: orbits, globe, rubik, wave, web, braid, ribbon/ring, and morph.
- Both tuned sizes: 20 and 64 points.
- Generated compile-time presets from pinned `orbs-spec.json`.
- Golden-vector parity with equal-depth dot multiset handling and strict far-to-near depth ordering.
- Public SwiftUI `ThinkingOrb` using `TimelineView` and `Canvas`.
- Automatic/light/dark themes, speed, pause, Reduce Motion, accessibility labels, and demo-only `reduceMotionOverride`.
- Native manually maintained `ThinkingOrbsDemo.xcodeproj` with controls sheet, all-state gallery, and UI tests. No XcodeGen.
- Demo navigation now uses a native two-item bottom tab bar. **All Animations** is the default tab; **Playground** centers the selected orb and presents its animation picker and settings in a bottom sheet.
- The demo now declares native iPhone and iPad device families. Its gallery, navigation, settings form, orientations, and cross-device UI tests adapt to compact and regular widths.
- MIT license, upstream provenance, README, ADRs, TODO, and machine-readable harness status.

## Verification

- Package parity and behavior: `swift test --scratch-path /private/tmp/thinking-orbs-kit-swift-build` — 21 tests in 11 suites passed; 0 failures.
- iOS package build: `xcodebuild build -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsKit -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/thinking-orbs-demo-dd2` — passed.
- Demo UI tests: `xcodebuild test -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsDemoUITests -derivedDataPath /private/tmp/thinking-orbs-demo-dd2` — 2 tests passed; controls and gallery covered.
- Demo build: `xcodebuild build -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/thinking-orbs-demo-dd2` — passed.
- Preset generation: `swift Scripts/generate-orb-spec.swift Upstream/orbs-spec.json /private/tmp/OrbSpec-final.swift` followed by a diff against `Sources/ThinkingOrbsKit/Generated/OrbSpec.swift` — no differences.
- Harness validation: `jq empty harness/features.json` and `git diff --check` — passed.
- Bottom-tab demo package verification: `swift test --scratch-path /private/tmp/thinking-orbs-kit-tabs-swift-build` — 21 tests in 11 suites passed; 0 failures.
- Bottom-tab demo build: `xcodebuild build -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/thinking-orbs-tabs-build` — passed.
- Bottom-tab demo UI tests: `xcodebuild test -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsDemoUITests -derivedDataPath /private/tmp/thinking-orbs-tabs-green` — 2 tests passed; default gallery tab and Playground settings sheet covered.
- iPad package parity: `swift test --scratch-path /private/tmp/thinking-orbs-kit-ipad-swift-build` — 21 tests in 11 suites passed; 0 failures.
- Universal demo build: `xcodebuild build -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/thinking-orbs-ipad-build` — passed; built `UIDeviceFamily` contains iPhone (`1`) and iPad (`2`).
- iPad UI tests: `xcodebuild test -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5),OS=latest' -only-testing:ThinkingOrbsDemoUITests -derivedDataPath /private/tmp/thinking-orbs-ipad-green-3` — 3 tests passed; native device family, multi-row gallery density, Playground centering, and settings coverage verified.
- iPhone regression UI tests: `xcodebuild test -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsDemoUITests -derivedDataPath /private/tmp/thinking-orbs-ipad-iphone-green` — 3 tests passed.
- Simulator: iPhone 17 Pro on iOS 26.5. Appearance and physical-device Instruments inspection were not performed.

## Decisions and risks

- The public renderer is wrapped in `#if os(iOS)` so host parity tests do not accidentally advertise macOS support. Add macOS only after the TODO checklist is completed.
- Equal-depth dots can receive different sub-tolerance ordering across JavaScript and Swift math libraries. Tests compare each dot as a unique multiset within `1e-4` and separately require monotonic depth order; lines remain ordered strictly.
- Manual visual, VoiceOver, and Instruments inspection remain release follow-ups. Automated golden parity, renderer behavior, and demo UI coverage are complete.
