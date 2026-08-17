# ThinkingOrbsKit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an independent iOS 15+ Swift Package that renders all nine `thinking-orbs` animations at both tuned sizes, verifies geometry against upstream golden vectors, and ships with a native demo app and controls sheet.

**Architecture:** Pure Swift geometry functions produce final `OrbFrame` dot and line lists from generated compile-time presets. `ThinkingOrb` is a thin SwiftUI `TimelineView`/`Canvas` renderer over that engine; a separate iPhone demo consumes the package through a local package reference. Vendored upstream spec and golden JSON pin parity to one exact MIT-licensed source revision.

**Tech Stack:** Swift tools 5.9, Swift 6-compatible source, SwiftUI, Foundation, Swift Package Manager, Swift Testing, Xcode 26.5 native project files, iOS Simulator, JSON golden fixtures.

## Global Constraints

- Repository: `/Users/nick/Documents/Work/Projects/ThinkingOrbsKit`, independent Git repository on `main`.
- Initial platform: iOS 15 and later only; do not claim macOS support in version 0.1.
- Record macOS package/demo/accessibility verification as future work in `TODO.md`.
- Port all nine states: working, searching, solving, listening, connecting, weaving, composing, breathing, and shaping.
- Ship only the separately tuned 20-point and 64-point sizes; do not expose arbitrary size scaling.
- Public API: `ThinkingOrb(state:size:theme:speed:paused:reduceMotionOverride:accessibilityLabel:)` plus `OrbState`, `OrbSize`, and `OrbTheme`.
- Use native SwiftUI `Canvas` and `TimelineView`; no WebKit, JavaScript runtime, Metal, SceneKit, SpriteKit, filters, blur, images, or external runtime dependency.
- Pin upstream to `de85557ca220332586d070d8788c0e1d6e877a0d`, package `0.3.1`, spec `1.0.0` unless a newer revision is explicitly re-approved before implementation.
- Vendor `spec/orbs-spec.json` and `spec/orbs-golden.json`; preserve upstream MIT copyright and visible attribution.
- Match every golden dot and line within `1e-4`; missing, extra, or reordered marks fail parity.
- Keep package-consumer and maintainer builds free of Node, npm, TypeScript, Python, XcodeGen, and other project-generator requirements. Maintain and commit the native `.xcodeproj` directly.
- Normal verification is offline and deterministic after the pinned files are vendored.
- Use red-green TDD for every engine and public behavior. Watch each focused test fail for the intended missing/incorrect behavior before production implementation.
- Make atomic commits at the end of every task.

## Planned File Structure

```text
Package.swift
.gitignore
Sources/ThinkingOrbsKit/
  ThinkingOrb.swift
  OrbState.swift
  OrbSize.swift
  OrbTheme.swift
  Engine/
    OrbFrame.swift
    ModeOptions.swift
    OrbMath.swift
    OrbEngine.swift
    OrbitEngine.swift
    LatticeEngine.swift
    WebEngine.swift
    BraidEngine.swift
    RibbonEngine.swift
    MorphEngine.swift
  Generated/OrbSpec.swift
Tests/ThinkingOrbsKitTests/
  PublicTypesTests.swift
  OrbSpecTests.swift
  OrbMathTests.swift
  OrbitEngineTests.swift
  LatticeEngineTests.swift
  WebEngineTests.swift
  BraidEngineTests.swift
  RibbonEngineTests.swift
  MorphEngineTests.swift
  GoldenParityTests.swift
  RendererBehaviorTests.swift
  Support/GoldenFixtures.swift
  Fixtures/orbs-golden.json
Upstream/orbs-spec.json
Upstream/orbs-golden.json
Upstream/UPSTREAM.md
Scripts/generate-orb-spec.swift
ThinkingOrbsDemo/
  Info.plist
  ThinkingOrbsDemoApp.swift
  ContentView.swift
  ControlsView.swift
  GalleryView.swift
ThinkingOrbsDemoUITests/
  ThinkingOrbsDemoUITests.swift
ThinkingOrbsDemo.xcodeproj/
harness/features.json
harness/design.md
harness/adr.md
harness/handoff.md
AGENTS.md
TODO.md
README.md
LICENSE
```

---

### Task 1: Establish package contracts and repository harness

**Files:**
- Create: `.gitignore`
- Create: `Package.swift`
- Create: `Sources/ThinkingOrbsKit/OrbState.swift`
- Create: `Sources/ThinkingOrbsKit/OrbSize.swift`
- Create: `Sources/ThinkingOrbsKit/OrbTheme.swift`
- Create: `Tests/ThinkingOrbsKitTests/PublicTypesTests.swift`
- Create: `harness/features.json`
- Create: `harness/adr.md`
- Create: `harness/handoff.md`
- Create: `AGENTS.md`
- Create: `TODO.md`
- Create: `README.md`
- Create: `LICENSE`

**Interfaces:**
- Produces: public `OrbState`, `OrbSize`, `OrbTheme`; package/library/test target named `ThinkingOrbsKit`.
- Consumes: approved `harness/design.md`; no engine interfaces.

- [ ] **Step 1: Write failing public-type tests**

```swift
import Testing
@testable import ThinkingOrbsKit

struct PublicTypesTests {
    @Test func exposesAllUpstreamStatesInStableOrder() {
        #expect(OrbState.allCases.map(\.rawValue) == [
            "working", "searching", "solving", "listening", "connecting",
            "weaving", "composing", "breathing", "shaping"
        ])
    }

    @Test func exposesOnlyTheTwoTunedSizes() {
        #expect(OrbSize.allCases.map(\.rawValue) == [20, 64])
    }

    @Test func exposesAutomaticAndExplicitThemes() {
        #expect(OrbTheme.allCases.map(\.rawValue) == ["automatic", "light", "dark"])
    }

    @Test func suppliesUpstreamAccessibilityLabels() {
        let expected: [(OrbState, String)] = [
            (.working, "Working…"), (.searching, "Searching…"),
            (.solving, "Solving…"), (.listening, "Listening…"),
            (.connecting, "Connecting…"), (.weaving, "Weaving…"),
            (.composing, "Composing…"), (.breathing, "Thinking…"),
            (.shaping, "Shaping…")
        ]
        #expect(expected.allSatisfy { $0.0.accessibilityLabel == $0.1 })
    }
}
```

- [ ] **Step 2: Create the package manifest and verify the red state**

`Package.swift`:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ThinkingOrbsKit",
    platforms: [.iOS(.v15)],
    products: [.library(name: "ThinkingOrbsKit", targets: ["ThinkingOrbsKit"])],
    targets: [
        .target(
            name: "ThinkingOrbsKit",
            swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]
        ),
        .testTarget(name: "ThinkingOrbsKitTests", dependencies: ["ThinkingOrbsKit"])
    ]
)
```

Run:

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/PublicTypesTests
```

Expected: compilation fails because the three public enums do not exist.

- [ ] **Step 3: Implement the public enums and labels**

```swift
public enum OrbState: String, CaseIterable, Sendable {
    case working, searching, solving, listening, connecting
    case weaving, composing, breathing, shaping

    public var accessibilityLabel: String {
        switch self {
        case .working: "Working…"
        case .searching: "Searching…"
        case .solving: "Solving…"
        case .listening: "Listening…"
        case .connecting: "Connecting…"
        case .weaving: "Weaving…"
        case .composing: "Composing…"
        case .breathing: "Thinking…"
        case .shaping: "Shaping…"
        }
    }
}

public enum OrbSize: Double, CaseIterable, Sendable {
    case points20 = 20
    case points64 = 64
}

public enum OrbTheme: String, CaseIterable, Sendable {
    case automatic, light, dark
}
```

- [ ] **Step 4: Create the harness and repository documents**

Create `.gitignore` containing `.upstream-source/`, `.DS_Store`, `DerivedData/`, and Xcode user-data patterns. Write valid `harness/features.json` with product version `0.1.0`, iOS minimum `15.0`, all nine modes and both sizes marked `pending`, and acceptance entries matching `harness/design.md`. Write `harness/adr.md` with accepted decisions for native Swift geometry, vendored golden fixtures, compile-time presets, SwiftUI Canvas, iOS-only 0.1, and the checked-in demo project. Write `harness/handoff.md` with upstream pin, current phase, verification commands, and no unperformed results.

Root `AGENTS.md` must require reading all four harness files, preserving MIT provenance, red-green golden tests, no unsupported platform claims, atomic commits, and exact verification reporting. `TODO.md` must contain the approved macOS checklist and optional pixel snapshot work. `README.md` must state the project is under development and credit/link upstream. `LICENSE` must contain the exact upstream MIT text and `Copyright (c) 2026 Jakub Antalik`.

- [ ] **Step 5: Run focused tests and validate JSON**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/PublicTypesTests
jq empty harness/features.json
git diff --check
```

Expected: tests pass, JSON parses, and formatting check is clean.

- [ ] **Step 6: Commit the foundation**

```bash
git add .gitignore Package.swift Sources Tests AGENTS.md TODO.md README.md LICENSE harness
git commit -m "chore: establish ThinkingOrbsKit foundation"
```

---

### Task 2: Vendor upstream truth and generate preset constants

**Files:**
- Create: `Upstream/orbs-spec.json`
- Create: `Upstream/orbs-golden.json`
- Create: `Upstream/UPSTREAM.md`
- Create: `Tests/ThinkingOrbsKitTests/Fixtures/orbs-golden.json`
- Create: `Tests/ThinkingOrbsKitTests/Support/GoldenFixtures.swift`
- Create: `Sources/ThinkingOrbsKit/Engine/ModeOptions.swift`
- Create: `Sources/ThinkingOrbsKit/Generated/OrbSpec.swift`
- Create: `Scripts/generate-orb-spec.swift`
- Create: `Tests/ThinkingOrbsKitTests/OrbSpecTests.swift`
- Modify: `Package.swift`

**Interfaces:**
- Produces: internal `OrbMode`, `ModeOptions`, `OrbPreset`, `ResolvedPreset`, `OrbSpec.resolve(state:size:)`, and `GoldenFixtures.assertCases(for:frame:)`.
- Consumes: public enums from Task 1; upstream commit `de85557ca220332586d070d8788c0e1d6e877a0d`.

- [ ] **Step 1: Copy and document the pinned upstream files**

Create a local ignored reference checkout and copy the fixtures:

```bash
git clone --no-checkout https://github.com/Jakubantalik/thinking-orbs.git .upstream-source
git -C .upstream-source checkout de85557ca220332586d070d8788c0e1d6e877a0d
cp .upstream-source/spec/orbs-spec.json Upstream/orbs-spec.json
cp .upstream-source/spec/orbs-golden.json Upstream/orbs-golden.json
cp Upstream/orbs-golden.json Tests/ThinkingOrbsKitTests/Fixtures/orbs-golden.json
```

`Upstream/UPSTREAM.md` must record repository URL, commit, package `0.3.1`, spec `1.0.0`, import date `2026-08-17`, imported paths, `1e-4` tolerance, and the regeneration command. Engine tasks read exact formulas from `.upstream-source/src/engine/`; that directory remains ignored and is never shipped.

Modify the test target:

```swift
.testTarget(
    name: "ThinkingOrbsKitTests",
    dependencies: ["ThinkingOrbsKit"],
    resources: [.process("Fixtures")]
)
```

- [ ] **Step 2: Write failing preset-resolution tests**

```swift
import Testing
@testable import ThinkingOrbsKit

struct OrbSpecTests {
    @Test func resolvesEveryStateAndSizeFromGoldenMetadata() throws {
        let golden = try GoldenFixtures.load()
        for state in OrbState.allCases {
            for size in OrbSize.allCases {
                let key = "\(state.rawValue)-\(Int(size.rawValue))"
                let expected = try #require(golden.resolved[key])
                let actual = OrbSpec.resolve(state: state, size: size)
                #expect(actual.mode.rawValue == expected.mode)
                #expect(abs(actual.speed - expected.speed) <= golden.tolerance)
                #expect(Set(actual.options.values.keys) == Set(expected.opts.keys))
                for option in expected.opts {
                    let value = try #require(actual.options.values[option.key])
                    #expect(abs(value - option.value) <= golden.tolerance)
                }
            }
        }
    }
}
```

- [ ] **Step 3: Run the test and verify the red state**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/OrbSpecTests
```

Expected: compilation fails because `GoldenFixtures`, `OrbSpec`, and engine option types do not exist.

- [ ] **Step 4: Implement fixture decoding and preset types**

```swift
enum OrbMode: String, Codable, Sendable {
    case orbits, globe, rubik, wave, web, braid, ribbon, ring, morph
}

struct ModeOptions: Equatable, Sendable {
    var values: [String: Double]

    subscript(_ key: String, default fallback: Double) -> Double {
        values[key] ?? fallback
    }
}

struct OrbPreset: Equatable, Sendable {
    let speed: Double
    let count: Double
    let size: Double
    let extra: [String: Double]
}

struct ResolvedPreset: Equatable, Sendable {
    let mode: OrbMode
    let speed: Double
    let options: ModeOptions
}
```

`GoldenFixtures.swift` decodes `specVersion`, `tolerance`, `resolved`, and `cases`. A dot is six flattened values `(x,y,z,r,white,alpha)` and a line is seven `(x1,y1,x2,y2,white,alpha,width)`. Reject arrays whose counts are not exact multiples. It exposes these exact helpers used by every later engine task:

```swift
enum GoldenFixtures {
    static func load() throws -> GoldenFile
    static func assert(
        _ actual: OrbFrame,
        equals expected: GoldenCase,
        tolerance: Double
    ) throws
    static func assertCases(
        for state: OrbState,
        frame: (Double, Double, ModeOptions) -> OrbFrame
    ) throws
}
```

`assertCases` filters all eight cases for the requested state, resolves the exact state/size options through `OrbSpec`, calls the supplied mode function with the golden case's direct engine time, and delegates to `assert`.

- [ ] **Step 5: Implement the Swift spec generator**

`Scripts/generate-orb-spec.swift` must decode `Upstream/orbs-spec.json` and emit deterministic sorted Swift literals for state-to-mode, base profiles, presets, scaling keys, labels, static time `0.6`, and rubik/morph timings. It writes `Sources/ThinkingOrbsKit/Generated/OrbSpec.swift`; package builds never invoke it.

`OrbSpec.resolve` copies the base option dictionary, applies paired count scaling with `rounded(.toNearestOrAwayFromZero)`, preserves explicit zero counts, scales all radius keys, stores `rSizeMul`, then merges preset extras. Cache nothing mutable.

- [ ] **Step 6: Run the generator**

```bash
swift Scripts/generate-orb-spec.swift Upstream/orbs-spec.json Sources/ThinkingOrbsKit/Generated/OrbSpec.swift
```

Expected: the generated Swift file contains all nine state mappings and all 18 presets.

- [ ] **Step 7: Run focused tests and confirm generated stability**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/OrbSpecTests
swift Scripts/generate-orb-spec.swift Upstream/orbs-spec.json /private/tmp/OrbSpec.swift
diff -u Sources/ThinkingOrbsKit/Generated/OrbSpec.swift /private/tmp/OrbSpec.swift
```

Expected: all 18 preset combinations pass and regeneration produces no diff.

- [ ] **Step 8: Commit upstream inputs and generated spec**

```bash
git add Package.swift Upstream Scripts Sources/ThinkingOrbsKit/Engine/ModeOptions.swift Sources/ThinkingOrbsKit/Generated Tests
git commit -m "feat: add pinned orb specification"
```

---

### Task 3: Port shared frame and math primitives

**Files:**
- Create: `Sources/ThinkingOrbsKit/Engine/OrbFrame.swift`
- Create: `Sources/ThinkingOrbsKit/Engine/OrbMath.swift`
- Create: `Tests/ThinkingOrbsKitTests/OrbMathTests.swift`

**Interfaces:**
- Produces: `OrbDot`, `OrbLine`, `OrbFrame`, `OrbMath.lerp`, `frac`, `hash`, `valueNoise`, `fibonacciDirection`, `angleDelta`, `projector`, `radiusScale`, and `finalize`.
- Consumes: `ModeOptions` from Task 2.

- [ ] **Step 1: Write failing literal math tests**

```swift
import Testing
@testable import ThinkingOrbsKit

struct OrbMathTests {
    @Test func reproducesPinnedDeterministicPrimitives() {
        #expect(abs(OrbMath.hash(0, 1.7) - 0.9343791858918848) < 1e-12)
        #expect(abs(OrbMath.frac(-1.25) - 0.75) < 1e-12)
        #expect(abs(OrbMath.angleDelta(.pi * 1.5, 0) + .pi / 2) < 1e-12)
        #expect(abs(OrbMath.radiusScale(size: 64, power: 0.6) - 0.3957630383738824) < 1e-12)
    }

    @Test func finalizationCullsClampsAndSorts() {
        let frame = OrbMath.finalize(dots: [
            .init(x: 0, y: 0, z: 2, radius: 0.1, white: 0.5, alpha: 1),
            .init(x: 0, y: 0, z: -2, radius: 1, white: 0.5, alpha: 1),
            .init(x: 0, y: 0, z: 0, radius: 1, white: 0.5, alpha: 0.01)
        ], lines: [], minimumRadius: 0.3)
        #expect(frame.dots.map(\.z) == [-2, 2])
        #expect(frame.dots[1].radius == 0.3)
    }
}
```

- [ ] **Step 2: Run and verify the red state**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/OrbMathTests
```

Expected: compilation fails because the frame and math types do not exist.

- [ ] **Step 3: Port the shared primitives exactly**

```swift
struct OrbDot: Equatable, Sendable {
    let x, y, z, radius, white, alpha: Double
}

struct OrbLine: Equatable, Sendable {
    let x1, y1, x2, y2, white, alpha, width: Double
}

struct OrbFrame: Equatable, Sendable {
    let dots: [OrbDot]
    let lines: [OrbLine]
    static let empty = OrbFrame(dots: [], lines: [])
}

typealias OrbProjector = @Sendable (Double, Double, Double) -> (Double, Double, Double)
typealias ModeFrame = @Sendable (Double, Double, ModeOptions) -> OrbFrame
```

Translate `src/engine/core.ts` at the pinned commit statement-for-statement. Preserve JavaScript floor semantics for negative values, the `sin` hash constants, projection rotation order, alpha cull threshold `0.02`, radius clamp, and stable far-to-near sort. Add provenance URL and commit in the file header.

- [ ] **Step 4: Run focused tests**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/OrbMathTests
```

Expected: focused tests pass without warnings.

- [ ] **Step 5: Commit the shared math**

```bash
git add Sources/ThinkingOrbsKit/Engine/OrbFrame.swift Sources/ThinkingOrbsKit/Engine/OrbMath.swift Tests/ThinkingOrbsKitTests/OrbMathTests.swift
git commit -m "feat: port shared orb math"
```

---

### Task 4: Port the working orbit engine

**Files:**
- Create: `Sources/ThinkingOrbsKit/Engine/OrbitEngine.swift`
- Create: `Tests/ThinkingOrbsKitTests/OrbitEngineTests.swift`

**Interfaces:**
- Produces: `frameOrbits(size:time:options:) -> OrbFrame`.
- Consumes: `OrbMath`, `OrbSpec.resolve`, and golden fixture assertion support.

- [ ] **Step 1: Write the failing working-state parity test**

```swift
import Testing
@testable import ThinkingOrbsKit

struct OrbitEngineTests {
    @Test func workingMatchesAllEightGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .working) { size, time, options in
            frameOrbits(size: size, time: time, options: options)
        }
    }
}
```

- [ ] **Step 2: Run the test and verify the red state**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/OrbitEngineTests
```

Expected: compilation fails because `frameOrbits` does not exist.

- [ ] **Step 3: Port the working algorithm**

Implement the exact algorithm from pinned `src/engine/orbits.ts`: 0.82 sphere radius, yaw `t*0.12`, 12 seeded orbit planes, ghost paths, three signed-speed particles, depth radius/ink, and shared finalization.

```swift
func frameOrbits(size: Double, time: Double, options: ModeOptions) -> OrbFrame
```

- [ ] **Step 4: Run the focused test**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/OrbitEngineTests
```

Expected: all four timestamps at both sizes match within `1e-4`.

- [ ] **Step 5: Commit**

```bash
git add Sources/ThinkingOrbsKit/Engine/OrbitEngine.swift Tests/ThinkingOrbsKitTests/OrbitEngineTests.swift
git commit -m "feat: port working orb animation"
```

---

### Task 5: Port searching, solving, and listening lattice engines

**Files:**
- Create: `Sources/ThinkingOrbsKit/Engine/LatticeEngine.swift`
- Create: `Tests/ThinkingOrbsKitTests/LatticeEngineTests.swift`

**Interfaces:**
- Produces: `frameGlobe`, `frameRubik`, and `frameWave`, each `(size:time:options:) -> OrbFrame`.
- Consumes: Task 3 math and Task 2 timing/spec constants.

- [ ] **Step 1: Write failing parity tests**

```swift
import Testing
@testable import ThinkingOrbsKit

struct LatticeEngineTests {
    @Test func searchingMatchesGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .searching) { frameGlobe(size: $0, time: $1, options: $2) }
    }
    @Test func solvingMatchesGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .solving) { frameRubik(size: $0, time: $1, options: $2) }
    }
    @Test func listeningMatchesGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .listening) { frameWave(size: $0, time: $1, options: $2) }
    }
}
```

- [ ] **Step 2: Run the tests and verify the red state**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/LatticeEngineTests
```

Expected: compilation fails because the three lattice functions do not exist.

- [ ] **Step 3: Port pinned `src/engine/lattice.ts`**

Translate the shared `Move`, solve-cycle palindrome, move generation/application, latitude/longitude sampling, globe scan meridian, rubik active-band ink/radius, and dual-wave radial motion without changing evaluation order. Use spec timings `slotDuration=0.42`, `rest=1.2`.

- [ ] **Step 4: Run the focused tests**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/LatticeEngineTests
```

Expected: 24 golden cases pass.

- [ ] **Step 5: Commit**

```bash
git add Sources/ThinkingOrbsKit/Engine/LatticeEngine.swift Tests/ThinkingOrbsKitTests/LatticeEngineTests.swift
git commit -m "feat: port lattice orb animations"
```

---

### Task 6: Port the connecting web engine

**Files:**
- Create: `Sources/ThinkingOrbsKit/Engine/WebEngine.swift`
- Create: `Tests/ThinkingOrbsKitTests/WebEngineTests.swift`

**Interfaces:**
- Produces: `frameWeb(size:time:options:) -> OrbFrame`, including dots and lines.
- Consumes: Fibonacci directions, value noise, projection, interpolation, and finalization.

- [ ] **Step 1: Write a failing line-aware parity test**

```swift
import Testing
@testable import ThinkingOrbsKit

struct WebEngineTests {
    @Test func connectingMatchesDotsAndLinesAtBothSizes() throws {
        try GoldenFixtures.assertCases(for: .connecting) { size, time, options in
            frameWeb(size: size, time: time, options: options)
        }
    }
}
```

- [ ] **Step 2: Run the test and verify the red state**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/WebEngineTests
```

Expected: compilation fails because `frameWeb` does not exist.

- [ ] **Step 3: Port pinned `src/engine/web.ts`**

Preserve 0.8 radius, noise seeds and rates, unit-sphere renormalization, all-pairs threshold edges, proximity/depth alpha, node pulse, deterministic signal pairing, line width floor `0.6`, and lines-before-dots frame contract.

- [ ] **Step 4: Run the focused test**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/WebEngineTests
```

Expected: eight cases match all dots and all line endpoints/width/ink/alpha within tolerance.

- [ ] **Step 5: Commit**

```bash
git add Sources/ThinkingOrbsKit/Engine/WebEngine.swift Tests/ThinkingOrbsKitTests/WebEngineTests.swift
git commit -m "feat: port connecting orb animation"
```

---

### Task 7: Port the weaving braid engine

**Files:**
- Create: `Sources/ThinkingOrbsKit/Engine/BraidEngine.swift`
- Create: `Tests/ThinkingOrbsKitTests/BraidEngineTests.swift`

**Interfaces:**
- Produces: `frameBraid(size:time:options:) -> OrbFrame`.

- [ ] **Step 1: Write failing parity test**

```swift
import Testing
@testable import ThinkingOrbsKit

struct BraidEngineTests {
    @Test func weavingMatchesGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .weaving) { size, time, options in
            frameBraid(size: size, time: time, options: options)
        }
    }
}
```

- [ ] **Step 2: Run the test and verify the red state**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/BraidEngineTests
```

Expected: compilation fails because `frameBraid` does not exist.

- [ ] **Step 3: Port pinned `src/engine/braid.ts`**

Preserve the Fibonacci ghost sphere, three pole-to-pole strands, fractional drift, end fade, helical turns, radial over/under breathing, depth size/ink/alpha, and shared finalization.

- [ ] **Step 4: Run the focused test**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/BraidEngineTests
```

Expected: eight cases pass.

- [ ] **Step 5: Commit**

```bash
git add Sources/ThinkingOrbsKit/Engine/BraidEngine.swift Tests/ThinkingOrbsKitTests/BraidEngineTests.swift
git commit -m "feat: port weaving orb animation"
```

---

### Task 8: Port composing and breathing ribbon engines

**Files:**
- Create: `Sources/ThinkingOrbsKit/Engine/RibbonEngine.swift`
- Create: `Tests/ThinkingOrbsKitTests/RibbonEngineTests.swift`

**Interfaces:**
- Produces: shared `frameRibbon(size:time:options:) -> OrbFrame` used by composing and breathing presets.

- [ ] **Step 1: Write failing parity tests**

```swift
import Testing
@testable import ThinkingOrbsKit

struct RibbonEngineTests {
    @Test func composingMatchesGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .composing) { frameRibbon(size: $0, time: $1, options: $2) }
    }
    @Test func breathingMatchesGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .breathing) { frameRibbon(size: $0, time: $1, options: $2) }
    }
}
```

- [ ] **Step 2: Run the tests and verify the red state**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/RibbonEngineTests
```

Expected: compilation fails because `frameRibbon` does not exist.

- [ ] **Step 3: Port pinned `src/engine/ribbon.ts`**

Preserve optional ghost sphere, spin-controlled projection, face-on tilt cancellation, plane basis and normal, band multiplier rounding, two traveling waves, face-on radial deformation, non-face-on normal offset, edge-dependent dot size/ink, and depth alpha.

- [ ] **Step 4: Run the focused tests**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/RibbonEngineTests
```

Expected: 16 cases pass, including the breathing preset's zero ghost count.

- [ ] **Step 5: Commit**

```bash
git add Sources/ThinkingOrbsKit/Engine/RibbonEngine.swift Tests/ThinkingOrbsKitTests/RibbonEngineTests.swift
git commit -m "feat: port ribbon orb animations"
```

---

### Task 9: Port the shaping morph engine

**Files:**
- Create: `Sources/ThinkingOrbsKit/Engine/MorphEngine.swift`
- Create: `Tests/ThinkingOrbsKitTests/MorphEngineTests.swift`

**Interfaces:**
- Produces: `frameMorph(size:time:options:) -> OrbFrame`.

- [ ] **Step 1: Write failing parity test**

```swift
import Testing
@testable import ThinkingOrbsKit

struct MorphEngineTests {
    @Test func shapingMatchesHoldAndTransitionGoldenFrames() throws {
        try GoldenFixtures.assertCases(for: .shaping) { size, time, options in
            frameMorph(size: size, time: time, options: options)
        }
    }
}
```

- [ ] **Step 2: Run the test and verify the red state**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/MorphEngineTests
```

Expected: compilation fails because `frameMorph` does not exist.

- [ ] **Step 3: Port pinned `src/engine/morph.ts`**

Implement clockwise top-center circle, triangle, and five-vertex square paths; per-edge polygon arc length; smoothstep; 1.4-second hold; 0.9-second transition; 160-sample blended outline; arc-length resampling; density floor 6; pulse; and dot radius floor 0.35. Preserve loop boundary comparisons exactly.

- [ ] **Step 4: Run the focused test**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/MorphEngineTests
```

Expected: eight cases pass.

- [ ] **Step 5: Commit**

```bash
git add Sources/ThinkingOrbsKit/Engine/MorphEngine.swift Tests/ThinkingOrbsKitTests/MorphEngineTests.swift
git commit -m "feat: port shaping orb animation"
```

---

### Task 10: Add the complete engine registry and 72-case parity gate

**Files:**
- Create: `Sources/ThinkingOrbsKit/Engine/OrbEngine.swift`
- Create: `Tests/ThinkingOrbsKitTests/GoldenParityTests.swift`

**Interfaces:**
- Produces: `OrbEngine.frame(state:size:modeTime:) -> OrbFrame` and `OrbEngine.normalizedSpeed(_:)`.
- Consumes: all mode functions and resolved presets.

- [ ] **Step 1: Write the failing full-matrix test**

```swift
import Testing
@testable import ThinkingOrbsKit

struct GoldenParityTests {
    @Test func everyPinnedGoldenCaseMatches() throws {
        let golden = try GoldenFixtures.load()
        #expect(golden.cases.count == 72)
        for expected in golden.cases {
            let state = try #require(OrbState(rawValue: expected.state))
            let size = try #require(OrbSize(rawValue: Double(expected.size)))
            let frame = OrbEngine.frame(state: state, size: size, modeTime: expected.time)
            try GoldenFixtures.assert(frame, equals: expected, tolerance: golden.tolerance)
        }
    }
}
```

- [ ] **Step 2: Run the test and verify the red state**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/GoldenParityTests
```

Expected: compilation fails because `OrbEngine` does not exist.

- [ ] **Step 3: Implement the exhaustive registry**

`OrbEngine.frame` resolves the preset and exhaustively switches over `OrbMode` to the matching mode function using the already-scaled `modeTime`. `OrbEngine.normalizedSpeed` returns `1` for nonfinite input and clamps negative input to `0`. No mutable global cache. Clock and preset-speed multiplication remain renderer behavior, not golden geometry behavior.

- [ ] **Step 4: Run every package test**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
```

Expected: complete package suite passes; all 72 cases, 11,288 dots, and 341 lines match within `1e-4`.

- [ ] **Step 5: Commit the registry and parity gate**

```bash
git add Sources/ThinkingOrbsKit/Engine/OrbEngine.swift Tests/ThinkingOrbsKitTests/GoldenParityTests.swift
git commit -m "test: enforce complete upstream parity"
```

---

### Task 11: Build the public SwiftUI renderer

**Files:**
- Create: `Sources/ThinkingOrbsKit/ThinkingOrb.swift`
- Create: `Tests/ThinkingOrbsKitTests/RendererBehaviorTests.swift`

**Interfaces:**
- Produces: approved public `ThinkingOrb` initializer and internal `OrbRenderBehavior`/`OrbInk` pure helpers.
- Consumes: `OrbEngine`, `OrbState`, `OrbSize`, and `OrbTheme`.

- [ ] **Step 1: Write failing renderer-behavior tests**

```swift
import Foundation
import Testing
@testable import ThinkingOrbsKit

struct RendererBehaviorTests {
    @Test func resolvesThemeAndMirrorsInk() {
        #expect(OrbInk.gray(white: 0.2, dark: false) == 0.2)
        #expect(OrbInk.gray(white: 0.2, dark: true) == 0.8)
    }

    @Test func reduceMotionUsesPinnedStaticModeTime() {
        #expect(
            OrbRenderBehavior.modeTime(
                date: .distantFuture,
                reduceMotion: true,
                presetSpeed: 9,
                userSpeed: 2
            ) == 0.6
        )
    }

    @Test func normalizesInvalidSpeed() {
        #expect(OrbEngine.normalizedSpeed(.nan) == 1)
        #expect(OrbEngine.normalizedSpeed(-2) == 0)
        #expect(OrbEngine.normalizedSpeed(1.5) == 1.5)
    }
}
```

- [ ] **Step 2: Run the tests and verify the red state**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/RendererBehaviorTests
```

Expected: compilation fails because `OrbInk` and `OrbRenderBehavior` do not exist.

- [ ] **Step 3: Implement `ThinkingOrb`**

Use `@Environment(\.colorScheme)` and `@Environment(\.accessibilityReduceMotion)`. Accept `reduceMotionOverride: Bool?` and use it only when nonnil; otherwise use the system environment. `TimelineView(.animation(paused: paused || effectiveReduceMotion))` supplies the shared date. `OrbRenderBehavior.modeTime` returns `0.6` directly under effective Reduce Motion; otherwise it returns `date.timeIntervalSinceReferenceDate * preset.speed * OrbEngine.normalizedSpeed(userSpeed)`. Canvas size is the enum's raw value. Draw `frame.lines` first with `context.stroke`, then `frame.dots` with ellipse fills. Clamp white to `0...1`, mirror for dark, preserve alpha, and expose one accessibility element with the caller label or state default.

```swift
public init(
    state: OrbState = .working,
    size: OrbSize = .points64,
    theme: OrbTheme = .automatic,
    speed: Double = 1,
    paused: Bool = false,
    accessibilityLabel: String? = nil
)
```

- [ ] **Step 4: Run focused tests and package build**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsKitTests/RendererBehaviorTests
xcodebuild build -quiet -scheme ThinkingOrbsKit -destination 'generic/platform=iOS Simulator'
```

Expected: focused tests and iOS package build pass without warnings.

- [ ] **Step 5: Commit the renderer**

```bash
git add Sources/ThinkingOrbsKit/ThinkingOrb.swift Tests/ThinkingOrbsKitTests/RendererBehaviorTests.swift
git commit -m "feat: add public ThinkingOrb view"
```

---

### Task 12: Create the iPhone demo with controls sheet and gallery

**Files:**
- Create: `ThinkingOrbsDemo/Info.plist`
- Create: `ThinkingOrbsDemo/ThinkingOrbsDemoApp.swift`
- Create: `ThinkingOrbsDemo/ContentView.swift`
- Create: `ThinkingOrbsDemo/ControlsView.swift`
- Create: `ThinkingOrbsDemo/GalleryView.swift`
- Create: `ThinkingOrbsDemoUITests/ThinkingOrbsDemoUITests.swift`
- Create: `ThinkingOrbsDemo.xcodeproj/project.pbxproj`
- Create: `ThinkingOrbsDemo.xcodeproj/project.xcworkspace/contents.xcworkspacedata`
- Create: `ThinkingOrbsDemo.xcodeproj/xcshareddata/xcschemes/ThinkingOrbsDemo.xcscheme`

**Interfaces:**
- Consumes: only public `ThinkingOrbsKit` API through a local package reference.
- Produces: iPhone app scheme `ThinkingOrbsDemo`, UI-test scheme coverage, and controls for every public option.

- [ ] **Step 1: Create the native Xcode project directly**

Create and commit a standard Xcode project without a generator. The project contains:

```text
Project: ThinkingOrbsDemo
App target: ThinkingOrbsDemo
UI test target: ThinkingOrbsDemoUITests
Shared scheme: ThinkingOrbsDemo (builds app, runs UI tests)
Local package reference: repository root `.`
Linked package product: ThinkingOrbsKit on the app target
App deployment target: iOS 15.0
UI-test deployment target: iOS 15.0
Swift language version: 6.0
Targeted device family: 1 (iPhone)
Bundle identifiers: com.thinkingorbs.demo and com.thinkingorbs.demoUITests
Info plist: ThinkingOrbsDemo/Info.plist
```

`project.pbxproj` must use explicit `PBXFileReference` and `PBXBuildFile` entries for every app and UI-test Swift file, `XCLocalSwiftPackageReference` with `relativePath = .`, and `XCSwiftPackageProductDependency` with `productName = ThinkingOrbsKit`. The shared scheme includes `ThinkingOrbsDemoUITests` in its TestAction. Do not create user-specific `xcuserdata`.

- [ ] **Step 2: Create a minimal app shell and failing UI tests**

Create the app entry point and a temporary `ContentView` containing only `Text("ThinkingOrbs Demo")`. Add UI tests:

```swift
import XCTest

@MainActor
final class ThinkingOrbsDemoUITests: XCTestCase {
    func testControlsSheetExposesEveryPublicOption() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["Controls"].waitForExistence(timeout: 2))
        app.buttons["Controls"].tap()
        for label in ["State", "Size", "Theme", "Speed"] {
            XCTAssertTrue(app.staticTexts[label].exists || app.switches[label].exists)
        }
        app.swipeUp()
        XCTAssertTrue(app.switches["Paused"].exists)
        XCTAssertTrue(app.switches["Reduce Motion Preview"].exists)
    }

    func testGalleryShowsFirstAndLastStates() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["All Animations"].tap()
        XCTAssertTrue(app.staticTexts["Working"].waitForExistence(timeout: 2))
        for _ in 0..<5 where !app.staticTexts["Shaping"].exists {
            app.swipeUp()
        }
        XCTAssertTrue(app.staticTexts["Shaping"].exists)
    }
}
```

Run:

```bash
xcodebuild test -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsDemoUITests
```

Expected: UI tests fail because Controls and All Animations do not exist.

- [ ] **Step 3: Implement the demo views**

`ContentView` owns `@State` for `.working`, `.points64`, `.automatic`, speed `1`, paused `false`, forced Reduce Motion `false`, controls-sheet presentation, and gallery navigation. It displays the selected orb, state label, an inline 20-point comparison, **Controls**, and **All Animations**.

`ControlsView` accepts bindings for all six controls, wraps content in `NavigationView`, uses Form sections, state Picker, segmented size/theme pickers, speed Slider `0.25...2` with Reset, paused Toggle, forced Reduce Motion Toggle, and Done toolbar action.

`GalleryView` uses `LazyVGrid` to render every `OrbState` at 64 points plus its label and a 20-point instance. Pass the demo-only forced setting through `reduceMotionOverride: forcedReduceMotion` on previews.

- [ ] **Step 4: Run demo UI tests and build the native project**

```bash
xcodebuild test -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsDemoUITests
xcodebuild build -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'generic/platform=iOS Simulator'
```

Expected: UI tests pass and the directly maintained native project builds without warnings.

- [ ] **Step 5: Commit the demo**

```bash
git add ThinkingOrbsDemo ThinkingOrbsDemoUITests ThinkingOrbsDemo.xcodeproj
git commit -m "feat: add ThinkingOrbs demo app"
```

---

### Task 13: Complete documentation, harness status, and release verification

**Files:**
- Modify: `README.md`
- Modify: `TODO.md`
- Modify: `harness/features.json`
- Modify: `harness/adr.md`
- Modify: `harness/handoff.md`
- Modify: `Upstream/UPSTREAM.md`

**Interfaces:**
- Consumes: completed package, tests, demo, and pinned provenance.
- Produces: reproducible contributor/release documentation; no runtime API.

- [ ] **Step 1: Finish package and demo documentation**

README must include local-path SPM installation without inventing an uncreated remote URL, complete public API example, nine-state table, both sizes, theme/speed/pause behavior, Reduce Motion/accessibility behavior, demo instructions, upstream credit, license, parity guarantee, and iOS 15+ support statement. It must not claim macOS support.

Update `harness/features.json` statuses only for behavior actually verified. Append accepted implementation ADRs without changing earlier records. Update `harness/handoff.md` with exact commands, results, commit pin, test counts, decisions, and observed risks. Confirm `TODO.md` retains the macOS checklist.

- [ ] **Step 2: Run the full verification matrix**

```bash
xcodebuild test -quiet -scheme ThinkingOrbsKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest'
xcodebuild build -quiet -scheme ThinkingOrbsKit -destination 'generic/platform=iOS Simulator'
xcodebuild test -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' -only-testing:ThinkingOrbsDemoUITests
xcodebuild build -quiet -project ThinkingOrbsDemo.xcodeproj -scheme ThinkingOrbsDemo -destination 'generic/platform=iOS Simulator'
jq empty harness/features.json
swift Scripts/generate-orb-spec.swift Upstream/orbs-spec.json /private/tmp/OrbSpec.swift
diff -u Sources/ThinkingOrbsKit/Generated/OrbSpec.swift /private/tmp/OrbSpec.swift
git diff --check
git status --short
```

Expected: package tests, package build, and demo build pass; JSON is valid; generated spec is current; formatting is clean; only intended documentation edits remain.

- [ ] **Step 3: Scan licensing and scope**

```bash
rg -n 'de85557ca220332586d070d8788c0e1d6e877a0d|Copyright \(c\) 2026 Jakub Antalik' Upstream README.md LICENSE Sources
rg -n 'macOS.*supported|supports macOS' README.md Package.swift
```

Expected: provenance appears in upstream/docs/source headers; no version 0.1 macOS support claim appears.

- [ ] **Step 4: Commit release documentation**

```bash
git add README.md TODO.md harness Upstream/UPSTREAM.md
git commit -m "docs: complete ThinkingOrbsKit handoff"
```

---

## Final Acceptance Checklist

- [ ] Independent repository and atomic commit history are intact.
- [ ] Package targets iOS 15+ and exposes no external dependency.
- [ ] All nine states render at both tuned sizes.
- [ ] All 72 golden cases, 11,288 dots, and 341 lines pass within `1e-4`.
- [ ] Public themes, speed, pause, shared clock, Reduce Motion, and accessibility labels work as designed.
- [ ] Demo app builds and exposes state, size, theme, speed, pause, forced Reduce Motion, and all-state gallery controls.
- [ ] Harness contains valid features, design, ADR, and handoff files.
- [ ] Exact upstream commit/spec/package version and MIT attribution are recorded.
- [ ] macOS remains in `TODO.md` and is not claimed as supported.
- [ ] Package consumers and maintainers need no Node, npm, TypeScript, Python, XcodeGen, other project generator, WebKit, or Photo Coach dependency.
- [ ] Final package tests and package/demo simulator builds pass without new compiler or Swift concurrency warnings.
