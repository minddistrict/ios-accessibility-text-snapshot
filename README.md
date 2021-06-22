# AccessibilityTextSnapshot

A [snapshot strategy](https://github.com/pointfreeco/swift-snapshot-testing#snapshot-anything) for testing your VoiceOvers support in UIKit, using the [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) library by PointFree.

## Usage

    import SnapshotTesting
    import AccessibilityTextSnapshot

    assertSnapshot(                     // SnapshotTesting gives you this...
        matching: someView,
        as: .recursiveA11yDescription)  // ... but AccessibilityTextSnapshot gives you this

## Installing with CocoaPods

    target 'MyAppTests' do
      pod 'AccessibilityTextSnapshot'
    end

