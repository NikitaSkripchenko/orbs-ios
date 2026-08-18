# ThinkingOrbsKit handoff

## Current state

- Version: 0.1.0
- Phase: iOS package and demo implementation complete
- Branch: `main`
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
- Demo navigation now uses a native two-item bottom tab bar. **All Animations** is the default tab; **Playground** centers the selected orb and exposes adaptive animation settings.
- The demo now declares native iPhone and iPad device families. Its gallery, navigation, settings form, orientations, and cross-device UI tests adapt to compact and regular widths.
- Regular-width iPad Playground now splits into a flexible orb preview and a persistent 320–420 point settings pane. iPhone and compact-width iPad retain the settings sheet.
- MIT license, upstream provenance, README, ADRs, TODO, and machine-readable harness status.
- Zero-speed timeline suspension and single-pass preset resolution in the renderer.
- Dedicated iOS consumer-module API tests and rendered accessibility UI coverage.
- Automated release performance, generated-source parity, iPhone/iPad UI, and secret checks in CI.
- DocC, changelog, security policy, and contributor/release guidance.

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
- Split Playground build: `xcodebuild build -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/thinking-orbs-ipad-split-build` — passed.
- Split Playground iPad UI tests: `xcodebuild test -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5),OS=latest' -only-testing:ThinkingOrbsDemoUITests -derivedDataPath /private/tmp/thinking-orbs-ipad-split-green` — 3 tests passed; persistent trailing settings pane, no redundant Settings button, control availability, gallery density, and preview/pane geometry covered.
- Split Playground iPhone UI tests: `xcodebuild test -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsDemoUITests -derivedDataPath /private/tmp/thinking-orbs-ipad-split-iphone-green` — 3 tests passed; compact settings sheet behavior retained.
- Final split Playground package verification: `swift test --scratch-path /private/tmp/thinking-orbs-kit-ipad-split-swift-build` — 24 tests in 12 suites passed; 0 failures. Existing `PerformanceBudgetTests` compiler warnings remain unrelated to this UI change.
- Reference-size iPad UI tests: `xcodebuild test -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M5),OS=latest' -only-testing:ThinkingOrbsDemoUITests -derivedDataPath /private/tmp/thinking-orbs-ipad-split-11-green` — 3 tests passed.
- Final iPhone UI regression: `xcodebuild test -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsDemoUITests -derivedDataPath /private/tmp/thinking-orbs-ipad-split-iphone-final` — 3 tests passed.
- Simulators: iPhone 17 Pro plus iPad Pro 11-inch and 13-inch on iOS 26.5. Physical-device Instruments inspection was not performed.

### Audit remediation verification — 2026-08-18

- Package tests: `swift test --scratch-path /private/tmp/thinking-orbs-final-debug` — 25 tests in 12 suites passed; 0 failures.
- Host engine/helper coverage: `swift test --enable-code-coverage` plus `llvm-cov report` — 99.67% line coverage; the iOS-only public view is covered separately by consumer and UI tests.
- Release performance: `THINKING_ORBS_GALLERY_BUDGET_MS=2 swift test -c release --scratch-path /private/tmp/thinking-orbs-final-release --filter PerformanceBudgetTests` — passed in 0.078 seconds for 500 nine-orb ticks, approximately 0.156 milliseconds per tick.
- iOS public API: `xcodebuild test -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsKitIOSTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -derivedDataPath /private/tmp/thinking-orbs-final-api-tests` — 3 tests passed.
- Universal demo build: `xcodebuild build -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/thinking-orbs-final-demo-build` — passed.
- iPhone UI and accessibility: `xcodebuild test ... -only-testing:ThinkingOrbsDemoUITests` — 4 tests passed.
- iPad adaptive UI and accessibility: `xcodebuild test ... -only-testing:ThinkingOrbsDemoUITests` — 4 tests passed.
- DocC: `xcodebuild docbuild -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsKit -destination 'generic/platform=iOS Simulator'` — passed.
- Secret scan: `Scripts/check-secrets.sh` — no high-confidence credential patterns found.

## Decisions and risks

- The public renderer is wrapped in `#if os(iOS)` so host parity tests do not accidentally advertise macOS support. Add macOS only after the TODO checklist is completed.
- Equal-depth dots can receive different sub-tolerance ordering across JavaScript and Swift math libraries. Tests compare each dot as a unique multiset within `1e-4` and separately require monotonic depth order; lines remain ordered strictly.
- Manual visual, VoiceOver, and Instruments inspection remain release follow-ups. Automated golden parity, renderer behavior, and demo UI coverage are complete.
- No git remote or release tag exists yet. Publishing version 0.1.0 remains an external release step after physical-device validation.
- `xcrun devicectl list devices` found the paired iPhone 16 Pro in `unavailable` state, so physical-device Instruments and energy profiling could not run in this session.
