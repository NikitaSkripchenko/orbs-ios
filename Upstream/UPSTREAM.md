# Upstream provenance

- Repository: https://github.com/Jakubantalik/thinking-orbs
- Commit: `de85557ca220332586d070d8788c0e1d6e877a0d`
- Package version: `0.3.1`
- Spec version: `1.0.0`
- Imported: 2026-08-17
- Geometry tolerance: `1e-4`
- Imported files: `spec/orbs-spec.json`, `spec/orbs-golden.json`

The ignored `.upstream-source/` checkout supplies formula-level reference files during maintenance. Regenerate Swift constants with:

```bash
swift Scripts/generate-orb-spec.swift Upstream/orbs-spec.json Sources/ThinkingOrbsKit/Generated/OrbSpec.swift
```

Run the complete iOS parity suite after any upstream refresh.
