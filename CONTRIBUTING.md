# Contributing to ThinkingOrbsKit

ThinkingOrbsKit is an iOS 15+ Swift Package with pinned upstream geometry. Keep changes
small, dependency-free, and verifiable offline.

## Prerequisites

- For package consumers: Swift 5.9 or later and an iOS 15+ application target.
- For repository development: a macOS machine with Xcode 16 or later and Swift 6. The demo uses Swift 6 language mode; package tests use Swift Testing.
- An installed iOS Simulator runtime compatible with the selected Xcode.

## Run the checks

Run deterministic geometry and behavior tests:

```bash
swift test
```

Run the release performance budget:

```bash
THINKING_ORBS_GALLERY_BUDGET_MS=2 \
  swift test -c release --filter PerformanceBudgetTests
```

List installed simulators with `xcrun simctl list devices available`. Replace
`<SIMULATOR_UDID>` below with an available iPhone or iPad identifier.

Run public API tests on iOS:

```bash
xcodebuild test -quiet \
  -project ThinkingOrbsDemo.xcodeproj \
  -scheme ThinkingOrbsKitIOSTests \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_UDID>'
```

Build the universal demo:

```bash
xcodebuild build -quiet \
  -project ThinkingOrbsDemo.xcodeproj \
  -scheme ThinkingOrbsDemo \
  -destination 'generic/platform=iOS Simulator'
```

Run UI regressions on iPhone and iPad (repeat with each simulator identifier):

```bash
xcodebuild test -quiet \
  -project ThinkingOrbsDemo.xcodeproj \
  -scheme ThinkingOrbsDemo \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_UDID>' \
  -only-testing:ThinkingOrbsDemoUITests \
  -parallel-testing-enabled NO
```

The rendered pause test verifies that changing speed preserves a frozen frame and
that playback resumes. `testDemoFollowsSystemReduceMotion` checks both demo tabs
against the simulator's current system setting. CI additionally enables system
Reduce Motion, sets `TEST_RUNNER_EXPECTED_REDUCE_MOTION=1`, runs that test alone,
and restores the setting. See `.github/workflows/ci.yml` for the exact commands.
UI comparisons allow two 8-bit color steps for Canvas rasterization noise;
geometry comparisons retain the pinned `1e-4` tolerance.

Xcode 27's XCTest libraries require iOS 17 even though the app/package deployment
target is iOS 15. This can produce linker warnings for the test targets; run tests
on an SDK-compatible runtime. An iOS 15 deployment build is not a substitute for
manual runtime validation on the oldest supported OS.

Scan the working tree and history for high-confidence credential patterns:

```bash
Scripts/check-secrets.sh
```

## Change engine behavior

1. Add a failing regression test.
2. Keep geometry pure and separate from SwiftUI rendering.
3. Preserve `Upstream/orbs-spec.json` and `Upstream/orbs-golden.json` as pinned truth.
4. Match all golden values within `1e-4`; do not weaken the tolerance.
5. Run the complete verification suite.

## Refresh upstream data

Update `Upstream/UPSTREAM.md` with the new revision, then regenerate presets:

```bash
swift Scripts/generate-orb-spec.swift \
  Upstream/orbs-spec.json \
  /private/tmp/OrbSpec.swift
diff -u Sources/ThinkingOrbsKit/Generated/OrbSpec.swift /private/tmp/OrbSpec.swift
```

Commit updated generated source and golden fixtures together with their passing tests.

## Prepare a release

1. Complete the physical-device Instruments, VoiceOver, and visual checks.
2. Update `CHANGELOG.md` with the release date.
3. Verify the repository is clean and CI is green.
4. Create the remote repository if needed and add it as `origin`.
5. Tag the release using the version number, then push the branch and tag.

Do not claim macOS support until every validation item in `TODO.md` is complete.
