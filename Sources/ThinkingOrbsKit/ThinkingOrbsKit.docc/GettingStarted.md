# Display a Thinking Orb

Add ThinkingOrbsKit to an iOS app and show an accessible progress animation.

## Add the package

For local development, add this repository as a local Swift Package dependency in
Xcode and link the `ThinkingOrbsKit` product to your application target.

Until the first remote release is tagged, a package manifest can use a local path:

```swift
.package(path: "../ThinkingOrbsKit")
```

## Show the first orb

Import the package in a SwiftUI view and select the activity being represented:

```swift
import SwiftUI
import ThinkingOrbsKit

struct SearchStatus: View {
    var body: some View {
        HStack(spacing: 12) {
            ThinkingOrb(state: .searching, size: .points20)
            Text("Finding similar photos")
        }
    }
}
```

The orb supplies the default VoiceOver label `Searching…`. Use
`accessibilityLabel` when the product needs more specific wording:

```swift
ThinkingOrb(
    state: .searching,
    accessibilityLabel: "Finding similar photos"
)
```

## Configure motion and appearance

```swift
ThinkingOrb(
    state: .composing,
    size: .points64,
    theme: .automatic,
    speed: 1.25,
    paused: false
)
```

Speed changes preserve the current phase. Zero speed and `paused` freeze it;
resuming continues from that phase. Finite speed is clamped to `0...100`;
nonfinite speed uses `1`. New running instances share an initial phase, while individually
changed speed/pause histories can diverge.

Keep `reduceMotionOverride` set to `nil` in production. This lets the system Reduce
Motion preference remain authoritative.

## Verify the integration

Build the application for an iOS simulator. Package maintainers can also run the
public consumer-module tests. Replace `<SIMULATOR_UDID>` with an identifier from
`xcrun simctl list devices available`:

```bash
xcodebuild test -quiet \
  -project ThinkingOrbsDemo.xcodeproj \
  -scheme ThinkingOrbsKitIOSTests \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_UDID>'
```

## Troubleshooting

- If `ThinkingOrb` is unavailable on macOS, use an iOS target. Version 0.1 does not
  claim macOS support.
- If animation is static, check `paused`, `speed`, and the system Reduce Motion setting.
- If Xcode cannot resolve the local package, confirm the repository path and product
  linkage in the consuming target.
