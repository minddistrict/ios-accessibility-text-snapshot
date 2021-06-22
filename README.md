# AccessibilityTextSnapshot

A [snapshot strategy](https://github.com/pointfreeco/swift-snapshot-testing#snapshot-anything) for testing your VoiceOvers support in UIKit, using the [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing) library by PointFree.

This strategy uses a _textual_ representation of the view hierarchy, focusing on just the information that is relevant for VoiceOver. (Related work: [AccessibilitySnapshot](https://github.com/cashapp/AccessibilitySnapshot) is a _visual_ snapshot-test tool for a similar use case.)

## Usage

    import SnapshotTesting
    import AccessibilityTextSnapshot

    assertSnapshot(                     // SnapshotTesting gives you this...
        matching: someView,
        as: .recursiveA11yDescription)  // ... but AccessibilityTextSnapshot gives you this

This generates a recursive (textual) description of all voiceover-relevant information, suitable for snapshot testing.

The string shows
    * all UIView subclasses with isAccessibilityElement true, together with their ancestor UIViews (if any) to show hierarchy
    * their voiceover-relevant properties (accessibilityValue, accessibilityLabel, etc)
    * any a11y-relevant *sub*views they might have, prefixed by `| ` to emphasise that they are *not* involved in VoiceOver

It does *not* show UIImageViews, which we maybe should reconsider at some point.

Example:

    * UIView                                       // non-a11y view but has a11y-relevant descendant
       * UIScrollView                              // (same)
         * UIView                                  // (same)
           * UIStackView                           // ...
             * MDViewLayer.ElementView
               * UIStackView
                 * MDViewModels.Label              // | hanging from this view means it has a11y-relevant stuff
                 | -label: Relaxation exercises    // a11y property
                 | -traits: .staticText            // a11y property
                 * UIStackView
                   * MDViewLayer.MultilineButton
                   | -label: Yes
                   | -hint: Unselected option
                   | -traits: .button
                   * MDViewLayer.MultilineButton
                   | -label: No
                   | -hint: Unselected option
                   | -traits: .button
             * MDViewLayer.ConversationListItemView // hanging | means a11y-relevant view
             | -label: Only you. No messages yet    // a11y property
             | -hint: Open conversation             // a11y property
             | * UIStackView                        // subviews that would be a11y-relevant
             |   * UIStackView                      // BUT are not read by VoiceOver because
             |     * UIStackView                    // the parent view overrides, note leading |
             |       * MDViewModels.Label
             |       | -label: Only you
             |     * UIStackView
             |       * MDViewModels.Label
             |       | -label: No messages yet.
             |   * MDViewLayer.Button
             |     * UIView
             |       * MDViewModels.Label
             |       | -label: Ongoing video call
             o MDViewLayer.StepValidationView        // o means isHidden=true (on self or a parent)
             o -label: Please correct the errors above. Actions available
             o -action: Go to first error            // We still show it because we want to
             o * MDViewLayer.MultilineButton         // be reminded that there *could* be something!
             o | -label: Please correct the errors above



## Installing with CocoaPods

    target 'MyAppTests' do
      pod 'AccessibilityTextSnapshot'
    end

