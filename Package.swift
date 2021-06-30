// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "AccessibilityTextSnapshot",
    platforms: [.iOS(.v12)],
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
          from: "1.9.0"
      )
    ],
    targets: [
        .target(
            name: "AccessibilityTextSnapshot",
            dependencies: ["SnapshotTesting"],
            path: "Sources"
        ),
    ]
)
