// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ThinkingOrbsKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "ThinkingOrbsKit", targets: ["ThinkingOrbsKit"])
    ],
    targets: [
        .target(
            name: "ThinkingOrbsKit",
            swiftSettings: [.enableUpcomingFeature("StrictConcurrency")]
        ),
        .testTarget(
            name: "ThinkingOrbsKitTests",
            dependencies: ["ThinkingOrbsKit"]
        )
    ]
)
