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

## Allow higher refresh rates

The default animation schedule uses a minimum interval of `1/60` second. Opt in
with `ThinkingOrb(state: .working, allowsHighRefreshRate: true)` to use `1/120`.
Changing this option preserves phase, speed, pause, and Reduce Motion behavior.

For higher refresh rates on supported iPhones, add this Boolean key to the
**consuming app's** Info.plist (the package cannot configure it for you):

```xml
<key>CADisableMinimumFrameDurationOnPhone</key>
<true/>
```

This allows up to 120 fps on supported displays; it does not guarantee sustained
120 fps. The system controls actual cadence and may lower it for power, thermal,
or other conditions. The demo's Motion section includes an **Allow 120 FPS**
toggle, off by default, shared by Playground and every gallery orb.

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
