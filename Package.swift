// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ios-accessibility-text-snapshot",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "AccessibilityTextSnapshot",
            targets: ["AccessibilityTextSnapshot"]
        ),
    ],
    dependencies: [
        .package(
            name: "SnapshotTesting",
            url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
            .upToNextMajor(from: "1.8.0")
        )
    ],
    targets: [
        .target(
            name: "AccessibilityTextSnapshot",
            dependencies: ["SnapshotTesting"],
            path: "Sources"
        )
    ]
)
