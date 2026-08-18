# Contributing to ThinkingOrbsKit

ThinkingOrbsKit is an iOS 15+ Swift Package with pinned upstream geometry. Keep changes
small, dependency-free, and verifiable offline.

## Prerequisites

- A macOS development machine with Xcode and its command-line tools.
- An installed iOS Simulator runtime.
- Swift 5.9 or later package support.

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

Run public API tests on iOS:

```bash
xcodebuild test -quiet \
  -project ThinkingOrbsDemo.xcodeproj \
  -scheme ThinkingOrbsKitIOSTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
```

Build the universal demo:

```bash
xcodebuild build -quiet \
  -project ThinkingOrbsDemo.xcodeproj \
  -scheme ThinkingOrbsDemo \
  -destination 'generic/platform=iOS Simulator'
```

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
