# ThinkingOrbsKit agent guide

Before changing code, read `harness/features.json`, `harness/design.md`, `harness/adr.md`, and `harness/handoff.md`.

## Rules

- Preserve the upstream MIT license, provenance comments, pinned revision, and visible credit.
- Use red-green TDD for engine and public behavior changes.
- Treat `Upstream/orbs-spec.json` and `Upstream/orbs-golden.json` as pinned truth.
- Match every golden value within `1e-4`; do not weaken parity tolerances.
- Keep geometry pure and independent from SwiftUI rendering.
- Keep the package dependency-free and offline after upstream files are vendored.
- Do not use XcodeGen or another project generator.
- Do not claim macOS support until the `TODO.md` validation is complete.
- Make atomic commits and record exact verification evidence in `harness/handoff.md`.
