# ``ThinkingOrbsKit``

Render nine deterministic thinking animations as native, accessible SwiftUI views.

## Overview

ThinkingOrbsKit ports the geometry from Jakub Antalik's MIT-licensed
`thinking-orbs` project. It performs no networking or file I/O, has no runtime
dependencies, and supports iOS 15 and later.

Create an orb with production-ready defaults:

```swift
import ThinkingOrbsKit

ThinkingOrb(state: .searching)
```

Each orb follows the system color scheme and Reduce Motion preference. The view
exposes one image-like accessibility element instead of exposing each decorative dot.

## Topics

### Essentials

- <doc:GettingStarted>
- ``ThinkingOrb``

### Configuration

- ``OrbState``
- ``OrbSize``
- ``OrbTheme``
