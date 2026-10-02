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

### Social video exports — 2026-10-02

#### Revision: English copy and animated transitions

- User requested English-only video copy, removal of the on-screen “Original orbs” caption, and a more dynamic edit. All three exports now use “9 states”; the requested caption is removed. Attribution remains in the repository README, media README, source comments, license, and pinned upstream provenance.
- Added curved screen-space particle interpolation (0.72 seconds for Noir/Editorial, 0.48 for Pulse), opacity compensation for differing particle counts, smooth background transitions, camera movement, and faster animation playback. Noir/Editorial now include an additional hero state. Public engine and renderer behavior is unchanged.
- `bash media/social/render.sh --check` — passed particle transition endpoint, opacity conservation, count distribution, and cut-boundary render checks for all three variants.
- `bash media/social/render.sh` — rebuilt all three final MP4s, covers and soundtracks successfully.
- `python3 media/social/verify.py` — passed all three exports, English-only exporter copy, and absence of the removed caption. Each export has 540 frames, 1080×1920 resolution, 30 fps, 18-second duration, H.264 video and AAC stereo. Full decode passed; audio peaks remain −1.6/−1.5/−1.7 dBFS.
- Inspected the updated final-video storyboard at 1.5, 3.3, 6.3, 9.3 and 16 seconds, including intermediate particle transitions and the caption-free end cards. Updated the comparison image and English media README.
- Package tests were not repeated: this revision changes only the offline media exporter and artifacts; the 25 passing package tests recorded below remain the latest package verification.

- Added three locally rendered vertical presentations in `media/social`: Noir, Editorial, and Pulse. Each is 18 seconds, 1080×1920, 30 fps, H.264/yuv420p with AAC stereo, original synthesized audio, a cover image, and an upstream credit in the closing card.
- Applied the user's feedback to remove dense copy and code. Final compositions focus on enlarged engine animation, a nine-state gallery, minimal branding, and the repository URL.
- Exporter compiles the existing pure geometry sources without modifying them; 64-point geometry is enlarged for the promotional composition. It is not a screen recording and does not claim macOS package-renderer support.
- `bash media/social/render.sh` — completed all three final exports, 540 frames each.
- `python3 media/social/verify.py` — all three exports passed resolution, frame-count, duration, codec, full audio/video decode, and non-clipping audio checks. Final peaks: Noir −1.6 dBFS, Editorial −1.5 dBFS, Pulse −1.7 dBFS. Exact file sizes and checks are in `media/social/verification.json`.
- Visually reviewed `media/social/storyboard.jpg`, extracted from final MP4s at 1.5, 5, 9.5, 12, and 16 seconds: readable text, no overlaps, all nine states visible, upstream credit retained.
- `CLANG_MODULE_CACHE_PATH=/private/tmp/thinking-orbs-social-cache swift test --disable-sandbox --scratch-path /private/tmp/thinking-orbs-social-tests --cache-path /private/tmp/thinking-orbs-social-spm-cache --config-path /private/tmp/thinking-orbs-social-spm-config --security-path /private/tmp/thinking-orbs-social-spm-security` — 25 tests in 12 suites passed, 0 failures. The first attempt with default caches was blocked by filesystem permissions; the successful run used writable temporary caches.
- `git diff --check` — passed. No package, demo, pinned upstream, or public API source changes. No new iOS build was needed for these media-only additions.

- The public renderer is wrapped in `#if os(iOS)` so host parity tests do not accidentally advertise macOS support. Add macOS only after the TODO checklist is completed.
- Equal-depth dots can receive different sub-tolerance ordering across JavaScript and Swift math libraries. Tests compare each dot as a unique multiset within `1e-4` and separately require monotonic depth order; lines remain ordered strictly.
- Manual visual, VoiceOver, and Instruments inspection remain release follow-ups. Automated golden parity, renderer behavior, and demo UI coverage are complete.
- No git remote or release tag exists yet. Publishing version 0.1.0 remains an external release step after physical-device validation.
- `xcrun devicectl list devices` found the paired iPhone 16 Pro in `unavailable` state, so physical-device Instruments and energy profiling could not run in this session.

### Audit fixes — 2026-10-02: finite speed bounds

- Clamp finite user speed to `0...100`; nonfinite values still fall back to `1`. This prevents time overflow and integer-conversion traps in geometry. Pinned formulas and golden files are unchanged.
- RED: `CLANG_MODULE_CACHE_PATH=/private/tmp/orbs-audit-module-cache swift test --disable-sandbox --scratch-path /private/tmp/orbs-audit-debug --cache-path /private/tmp/orbs-audit-spm-cache --config-path /private/tmp/orbs-audit-spm-config --security-path /private/tmp/orbs-audit-spm-security --filter extremeFiniteSpeedProducesRenderableFrames` — failed as expected: mode time was infinity. Log: `/private/tmp/orbs-speed-red.log`.
- GREEN: same command without `--filter` — 26 tests in 12 suites passed, including every state/size at extreme finite speed and all 72 golden cases. Log: `/private/tmp/orbs-speed-green.log`.

### Audit fixes — 2026-10-02: continuous playback

- Added a pure playback clock retained by SwiftUI. Speed changes reanchor phase; pause/zero speed/Reduce Motion suspend it, and resuming excludes the suspended duration. New instances share the reference-date phase; independently controlled instances retain their own histories (ADR-009).
- Clock RED: the package command above with `--filter PlaybackClockTests` against the initial stateless adapter failed with 10 assertions, including a 40,600,000.5-second phase discontinuity. Log: `/private/tmp/orbs-clock-red.log`.
- Clock GREEN: full package command above — 33 tests in 13 suites passed; all 72 golden cases unchanged. Log: `/private/tmp/orbs-clock-green.log`.
- iOS build: `xcodebuild build -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'generic/platform=iOS Simulator' -derivedDataPath /private/tmp/orbs-fixes-ios` — passed. Log: `/private/tmp/orbs-clock-ios.log`.
- UI RED: restored the pre-clock renderer temporarily and ran `xcodebuild test -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'platform=iOS Simulator,id=EDBFC97C-1468-45EF-A5A9-C9D8EB531A66' -only-testing:ThinkingOrbsDemoUITests/ThinkingOrbsDemoUITests/testPausedOrbKeepsItsFrameAcrossSpeedChanges -parallel-testing-enabled NO` through XcodeBuildMCP. The verified-on pause changed by 233 color steps after a speed change (limit 2). Result: `~/Library/Developer/XcodeBuildMCP/workspaces/ThinkingOrbsKit-748abcc75b21/result-bundles/test_sim_2026-10-02T13-26-14-822Z_pid39909_a36ca1dd.xcresult`.
- UI GREEN: same destination, scheme, and command with `-only-testing:ThinkingOrbsDemoUITests` — 5 tests passed on iPhone 18 Pro Max / iOS 27. Result: `~/Library/Developer/XcodeBuildMCP/workspaces/ThinkingOrbsKit-748abcc75b21/result-bundles/test_sim_2026-10-02T13-27-31-754Z_pid39909_d003a7e7.xcresult`.
- Consumer API: same destination with scheme `ThinkingOrbsKitIOSTests`, no `-only-testing` — 3 tests passed. Views are now installed in `UIHostingController` rather than accessing `body` outside an environment. Result: `~/Library/Developer/XcodeBuildMCP/workspaces/ThinkingOrbsKit-748abcc75b21/result-bundles/test_sim_2026-10-02T13-29-46-844Z_pid39909_5c84dd9b.xcresult`.
- Test investigation: a hostless UIWindow could not drive Canvas animation, so the rendered regression lives in the demo UI target. SwiftUI Toggle rows required tapping the switch at the trailing edge and asserting its value. Decoded snapshots of an unchanged Canvas differed in seven pixels by one 8-bit color step; the UI comparison allows at most two color steps per channel. Golden geometry tolerance remains `1e-4`.
- Xcode 27 emits existing XCTest-link deployment warnings for the test targets (iOS 15 versus SDK XCTest minimum 17); package/demo deployment support is still iOS 15+.
