# ThinkingOrbsKit

ThinkingOrbsKit is a native SwiftUI port of all nine dotted thought-orb animations from [thinking-orbs](https://github.com/Jakubantalik/thinking-orbs).

Version 0.1 targets iOS 15 and later. macOS support is intentionally deferred and tracked in `TODO.md`.

## Local Swift Package installation

Until a remote release is published, add the package by local path:

```swift
dependencies: [
    .package(path: "../ThinkingOrbsKit")
]
```

Then add the `ThinkingOrbsKit` product to the application target and import it:

```swift
import ThinkingOrbsKit

ThinkingOrb(
    state: .searching,
    size: .points64,
    theme: .automatic,
    speed: 1,
    paused: false
)
```

## Installation with an LLM agent

Copy this prompt into your coding agent after making this repository available beside your SwiftUI app. Replace the package path and target name as needed:

```text
Integrate ThinkingOrbsKit into this SwiftUI iOS app.

1. Inspect the project first and identify the app target and its existing Swift Package dependency pattern.
2. Add the local package at <path-to-ThinkingOrbsKit> and link the ThinkingOrbsKit product to the <app-target-name> target. Do not invent a remote package URL.
```

## States and sizes

| State | Motion | Default label |
| --- | --- | --- |
| `working` | particles on tilted orbits | Working… |
| `searching` | scan meridian across a dotted globe | Searching… |
| `solving` | quarter-turn bands scramble and resolve | Solving… |
| `listening` | waveform rolls through latitude rings | Listening… |
| `connecting` | constellation nodes and signals | Connecting… |
| `weaving` | three strands plait around a sphere | Weaving… |
| `composing` | undulating multi-band sash | Composing… |
| `breathing` | face-on ring slowly morphs | Thinking… |
| `shaping` | dotted circle → triangle → square | Shaping… |

Two independently tuned sizes are available: `.points20` for inline use and `.points64` for larger status surfaces. They are not arbitrary scale factors.

## Behavior

- `OrbTheme.automatic` follows SwiftUI `colorScheme`; `.light` and `.dark` pin the monochrome ink.
- `speed` multiplies the baked state/size speed. Nonfinite values use `1`; negative values clamp to `0`.
- `paused` freezes the shared timeline phase.
- `reduceMotionOverride` is an optional demo/testing hook; production callers should omit it so system Reduce Motion remains authoritative.
- Reduce Motion renders the upstream representative static frame at `t = 0.6`.
- Every instance exposes one image-like accessibility element with the state label or a caller-provided override. Individual dots and lines remain decorative.
- All geometry is generated in memory and rendered with `Canvas`; there are no images, filters, WebKit views, or runtime JavaScript dependencies.

## Demo

Open `ThinkingOrbsDemo.xcodeproj` and run the `ThinkingOrbsDemo` scheme on an iPhone or iPad simulator. The demo opens to an all-state gallery and includes a Playground tab with a centered preview plus controls for state, size, theme, speed, pause, and Reduce Motion preview. Settings use a native sheet on iPhone and compact widths, then become a persistent trailing pane on regular-width iPad. Its grid and navigation also adapt to split-view and windowed layouts.

The project is maintained as native Xcode project files. No project generator is required.

## Documentation

- The package's DocC catalog contains a getting-started guide and complete symbol reference.
- [`CONTRIBUTING.md`](CONTRIBUTING.md) contains local verification, upstream refresh, and release steps.
- [`CHANGELOG.md`](CHANGELOG.md) records user-visible changes.
- [`SECURITY.md`](SECURITY.md) defines the security boundary and private reporting expectations.

## Verification

Run deterministic package tests:

```bash
swift test
```

Run the public API tests on the supported iOS platform:

```bash
xcodebuild test -quiet \
  -project ThinkingOrbsDemo.xcodeproj \
  -scheme ThinkingOrbsKitIOSTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
```

The CI workflow also enforces optimized geometry performance, generated-source parity,
iPhone/iPad UI behavior, and high-confidence credential scanning.

## Parity and provenance

The package vendors `Upstream/orbs-spec.json` and `Upstream/orbs-golden.json` from upstream commit `de85557ca220332586d070d8788c0e1d6e877a0d` (upstream package `0.3.1`, spec `1.0.0`). The test suite compares all 72 frozen cases within `1e-4` for positions, depth, radius, ink, alpha, lines, and counts. Equal-depth dots are compared as a geometry multiset while the actual frame still must be monotonically sorted far-to-near; this avoids undefined cross-platform ordering when a depth is numerically equal.

## License

The original animation design and engine math are MIT licensed and copyright © 2026 Jakub Antalik. See `LICENSE` and `Upstream/UPSTREAM.md`.
