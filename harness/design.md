# ThinkingOrbsKit design

## Product goal

ThinkingOrbsKit is an independent Swift Package that ports every animation from Jakub Antalik's MIT-licensed `thinking-orbs` project to native SwiftUI. It provides one small public component for iOS applications and a companion demo app for inspecting every supported state and tuning.

The first release targets iOS 15 and later. macOS support is intentionally deferred and must appear in `TODO.md` rather than being partially advertised or conditionally compiled in version 0.1.

## Repository boundary

The package lives in its own Git repository at:

```text
/Users/nick/Documents/Work/Projects/ThinkingOrbsKit
```

It does not remain nested in Photo Coach and does not depend on Photo Coach types. Photo Coach will later consume it through a local or remote Swift Package dependency and remove its private breathing-orb implementation in a separate integration change.

## Scope

### Included

- Native Swift implementations of all nine upstream states:
  - `working`
  - `searching`
  - `solving`
  - `listening`
  - `connecting`
  - `weaving`
  - `composing`
  - `breathing`
  - `shaping`
- Both upstream tuned sizes: 20 points and 64 points.
- Automatic, light, and dark monochrome themes.
- A nonnegative user speed multiplier and explicit pause control.
- Automatic Reduce Motion behavior using a representative static frame.
- Default state-specific accessibility labels with a caller override.
- Shared clock semantics so multiple visible instances remain synchronized.
- Golden-vector parity tests derived from the upstream spec and fixtures.
- A native iPhone and iPad demo app with adaptive settings controls and an all-state gallery.
- MIT licensing, attribution, upstream revision tracking, and release documentation.
- A dedicated `harness/` folder containing project guidance and handoff state.

### Excluded from version 0.1

- macOS support; record it in `TODO.md`.
- watchOS, tvOS, visionOS, Android, React Native, WebKit, or JavaScript execution.
- Arbitrary numeric sizes; the upstream 20-point and 64-point presets are separate tuned designs.
- Custom colors, gradients, blur, glow, Metal, SpriteKit, SceneKit, or image assets.
- Runtime loading or parsing of the upstream JSON specification.
- Node, npm, TypeScript, or code generation as a package-consumer requirement.
- Photo Coach-specific state, copy, or dependencies.

## Repository structure

```text
ThinkingOrbsKit/
├── Package.swift
├── Sources/
│   └── ThinkingOrbsKit/
│       ├── ThinkingOrb.swift
│       ├── OrbState.swift
│       ├── OrbSize.swift
│       ├── OrbTheme.swift
│       ├── Engine/
│       │   ├── OrbFrame.swift
│       │   ├── OrbMath.swift
│       │   ├── OrbEngine.swift
│       │   ├── GlobeEngine.swift
│       │   ├── OrbitEngine.swift
│       │   ├── RubikEngine.swift
│       │   ├── WaveEngine.swift
│       │   ├── WebEngine.swift
│       │   ├── BraidEngine.swift
│       │   ├── RibbonEngine.swift
│       │   └── MorphEngine.swift
│       ├── Generated/
│       │   └── OrbSpec.swift
│       └── ThinkingOrbsKit.docc/
├── Tests/
│   └── ThinkingOrbsKitTests/
├── ThinkingOrbsKitIOSTests/
├── Upstream/
│   ├── orbs-spec.json
│   ├── orbs-golden.json
│   └── UPSTREAM.md
├── ThinkingOrbsDemo/
├── ThinkingOrbsDemo.xcodeproj/
├── harness/
│   ├── features.json
│   ├── design.md
│   ├── adr.md
│   └── handoff.md
├── AGENTS.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md
├── TODO.md
├── README.md
└── LICENSE
```

`harness/design.md` is this document. The root `AGENTS.md` requires future agents to read all four harness files before changing code and contains build, testing, source-parity, licensing, and release rules.

## Public API

The package exports one SwiftUI component and three supporting enums:

```swift
public struct ThinkingOrb: View {
    public init(
        state: OrbState = .working,
        size: OrbSize = .points64,
        theme: OrbTheme = .automatic,
        speed: Double = 1,
        paused: Bool = false,
        reduceMotionOverride: Bool? = nil,
        accessibilityLabel: String? = nil
    )
}

public enum OrbState: String, CaseIterable, Sendable {
    case working
    case searching
    case solving
    case listening
    case connecting
    case weaving
    case composing
    case breathing
    case shaping
}

public enum OrbSize: Double, CaseIterable, Sendable {
    case points20 = 20
    case points64 = 64
}

public enum OrbTheme: String, CaseIterable, Sendable {
    case automatic
    case light
    case dark
}
```

Typical use:

```swift
ThinkingOrb(
    state: .searching,
    size: .points64,
    theme: .automatic,
    speed: 1,
    paused: false
)
```

The view owns no external state. Changing any input immediately changes subsequent rendered frames. Nonfinite speed falls back to `1`; finite speed is clamped to `0...100`. Changing speed preserves the current phase. Zero speed and explicit pause freeze that phase; resuming excludes the paused duration. `reduceMotionOverride` is an optional demo/testing hook; production callers should omit it so the system accessibility environment remains authoritative.

## Engine architecture

### Geometry contract

Every mode produces an `OrbFrame` from a resolved preset, canvas size, and time:

```swift
struct OrbFrame: Equatable, Sendable {
    let dots: [OrbDot]
    let lines: [OrbLine]
}
```

`OrbDot` contains final position, depth, radius, grayscale ink value, and alpha. `OrbLine` contains final endpoints, width, ink, and alpha. Geometry functions cull marks below the upstream alpha floor, clamp dot radii to the mode floor, and sort dots far-to-near. The SwiftUI renderer only draws the returned lists and does not reinterpret mode geometry.

### Shared math

`OrbMath` contains deterministic primitives shared by the nine modes: interpolation, wrapped angles, projection, Fibonacci-sphere directions, deterministic hashing, value noise, radius scaling, and frame finalization. Mode files remain small and mirror one upstream engine each.

### Presets

`Generated/OrbSpec.swift` contains compile-time constants generated from the vendored `orbs-spec.json` during repository maintenance. Generated values include state-to-mode mapping, labels, base profiles, size presets, count/radius scaling keys, static time, and transition timing.

Package builds do not run the generator. A maintainer-only script may regenerate `OrbSpec.swift` after updating the pinned upstream inputs, and the generated file is committed.

### Rendering

`ThinkingOrb` uses `TimelineView(.animation)` and `Canvas`. A pure `OrbPlaybackClock` stores an anchor date, accumulated phase, and rate. New instances derive their initial phase from the shared reference date. SwiftUI retains the clock in `@State` and reanchors it when speed or suspension changes, preserving continuity. Independently controlled instances can diverge after those changes; they do not jump back to a global phase. Each frame draws lines first, then depth-sorted circles using source-over composition. Rendering uses no filters or offscreen bitmap resources.

`OrbTheme.automatic` resolves from SwiftUI's `colorScheme`. Explicit themes override the environment. Dark appearance mirrors the upstream grayscale ink calculation. Reduce Motion renders the upstream representative static time, pauses the animation schedule, and suspends the playback clock; disabling it continues the previous animated phase.

## Accessibility

- Each `OrbState` supplies the upstream default label: Working, Searching, Solving, Listening, Connecting, Weaving, Composing, Thinking, or Shaping.
- The caller may replace the default label.
- The canvas is exposed as one image-like accessibility element; individual dots and lines are never exposed.
- Meaning does not rely on motion or color. Reduce Motion presents a stable representative frame while retaining the label.
- The two orb sizes remain visually fixed; accessibility text belongs to the surrounding product UI.

## Upstream synchronization and licensing

`Upstream/UPSTREAM.md` records:

- upstream repository URL;
- exact source commit;
- upstream package version;
- spec version;
- date imported;
- files imported;
- local regeneration and parity commands; and
- any intentional divergence.

The repository vendors `orbs-spec.json` and `orbs-golden.json` from that exact revision. It does not vendor React, demo, npm, or browser build tooling.

The root `LICENSE` preserves the upstream MIT license and copyright notice. `README.md` prominently credits Jakub Antalik and links to the original project and live demo. Derived Swift files retain concise provenance comments where formulas are ported directly.

## Demo application

`ThinkingOrbsDemo` is a checked-in native iPhone and iPad Xcode project targeting iOS 15 or later and depending on the sibling package through a local package reference.

The app uses a native bottom tab bar with **All Animations** selected by default and **Playground** as the second tab.

- **All Animations** presents all nine states in an adaptive grid for quick parity inspection.
- **Playground** centers a large live preview using the selected state, size, theme, speed, pause, and Reduce Motion settings.
- On iPhone and compact-width iPad windows, a bottom-anchored **Settings** button presents the animation picker and settings in a native sheet. On iOS 16 and later the sheet supports medium and large detents; iOS 15 uses the standard sheet presentation.
- On regular-width iPad, Playground uses a split layout: the orb stays centered in the flexible preview pane and the same settings form remains visible in a 320–420 point trailing pane. The divider and grouped background clarify the two regions without adding modal navigation.
- The gallery is centered at a readable maximum width, navigation remains single-column inside each tab, and all four iPad orientations are supported, including windowed and split-view size changes.

Both Playground settings presentations use the same native SwiftUI controls:

- state picker for all nine states;
- segmented size picker for 20 and 64 points;
- segmented theme picker for Automatic, Light, and Dark;
- speed slider from `0.25` through `2.0`, with a reset-to-1 action;
- paused toggle; and
- forced Reduce Motion preview toggle applied only through the demo-only `reduceMotionOverride` parameter.

The compact sheet uses a navigation title and Done action. The regular-width pane uses a persistent Settings header. Both use semantic styles, Dynamic Type, and scrollable content at large accessibility sizes. Demo state is in memory only.

## Harness files

`harness/features.json` is the machine-readable source of scope and acceptance status for all nine modes, both sizes, package behavior, demo behavior, parity, documentation, and deferred macOS support.

`harness/design.md` records the approved product and technical design.

`harness/adr.md` records durable decisions, including native Swift geometry, iOS-only version 0.1, vendored spec/golden fixtures, compile-time generated presets, SwiftUI Canvas rendering, and the checked-in demo project.

`harness/handoff.md` records implementation progress, exact verification commands and results, upstream revision, release readiness, and remaining risks.

## Testing and verification

### Golden-vector tests

Tests load `orbs-golden.json` as a test resource and evaluate every upstream state/size/timestamp case. They compare:

- resolved mode and preset values;
- dot count and line count;
- dot x, y, z/depth, radius, ink, and alpha;
- line endpoints, width, ink, and alpha; and
- far-to-near ordering.

Every numeric value must match within `1e-4`, the upstream port tolerance. Missing or extra marks fail the test.

### Unit behavior tests

- public enum coverage and raw values;
- default accessibility labels;
- state-to-mode mapping;
- size-specific preset resolution;
- light/dark ink mirroring;
- speed normalization;
- timeline pausing for explicit pause, zero speed, and Reduce Motion;
- default and custom accessibility-label resolution;
- resolved-preset frame dispatch; and
- an optimized all-state CPU geometry budget.

### iOS public API tests

The `ThinkingOrbsKitIOSTests` target imports the package without `@testable`. It builds the default view and every public state, size, theme, and initializer option on an iOS simulator. Demo UI tests verify that the rendered orb exposes its default image-like accessibility element.

### Build verification

Normal verification remains offline and deterministic:

```bash
xcodebuild test -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsKitIOSTests -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
xcodebuild build -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'generic/platform=iOS Simulator'
xcodebuild test -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5),OS=latest' -only-testing:ThinkingOrbsDemoUITests
```

The deterministic engine suite runs with `swift test`; this does not claim macOS renderer support because the public view remains iOS-only. The consumer-module test target must compile and run on an iOS simulator without warnings under strict concurrency checking. The demo must build for iPhone and iPad without a network dependency after package resolution.

### Performance sanity

The optimized all-state gallery geometry must average less than 2 milliseconds per tick in CI. Zero or negative normalized speed pauses the animation schedule, and the renderer reuses its resolved preset. A manual Instruments pass on a mid-range physical iPhone remains a release check because automated geometry timing does not measure SwiftUI Canvas drawing or device energy use.

## TODO and future work

`TODO.md` contains a scoped macOS item covering:

- adding `.macOS` to `Package.swift` only after verification;
- validating TimelineView lifecycle and window visibility;
- keyboard and pointer behavior in the demo;
- macOS accessibility inspection;
- package and demo builds on a supported macOS destination; and
- documenting any rendering differences.

It also records optional future snapshot/pixel-diff tooling. Neither item blocks the iOS 0.1 package when golden geometry, unit tests, and demo builds pass.

## Acceptance criteria

- The independent repository is initialized on `main` with atomic commits.
- `ThinkingOrbsKit` builds as a dependency-free iOS 15+ Swift Package.
- The public API renders all nine states at both 20-point and 64-point tuned sizes.
- Theme, speed, pause, Reduce Motion, shared-clock, and accessibility behavior match this design.
- Every vendored upstream golden case passes within `1e-4` for dots and lines.
- The iPhone and iPad demo project builds and its adaptive settings presentations exercise every public option.
- The demo gallery presents all nine states.
- `harness/` contains valid features, design, ADR, and handoff documents, and root `AGENTS.md` routes contributors to them.
- macOS support is documented in `TODO.md` and is not claimed by version 0.1.
- The exact upstream revision and spec version are recorded.
- MIT licensing and visible upstream attribution are present.
- No Node, npm, JavaScript runtime, WebKit, external package, or Photo Coach dependency is introduced.
