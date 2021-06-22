# AccessibilityTextSnapshot

A [snapshot strategy](https://github.com/pointfreeco/swift-snapshot-testing#snapshot-anything) for testing your VoiceOvers support in UIKit, using the [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) library by PointFree.

This strategy uses a _textual_ representation of the view hierarchy, focusing on just the information that is relevant for VoiceOver. (Related work: [AccessibilitySnapshot](https://github.com/cashapp/AccessibilitySnapshot) is a _visual_ snapshot-test tool for a similar use case.)

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

