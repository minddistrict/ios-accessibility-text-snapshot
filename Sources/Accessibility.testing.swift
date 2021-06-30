import Foundation
import UIKit
import SnapshotTesting

extension UIView {
    /** Generate a recursive description of all voiceover-relevant information, suitable for snapshot testing.

The string shows
    - all Views with isAccessibilityElement true, together with their ancestor Views (if any) to show hierarchy
    - their voiceover-relevant properties (accessibilityValue, accessibilityLabel, etc)
    - any a11y-relevant *sub*Views they might have, prefixed by `| ` to emphasise that they are *not* involved in VoiceOver

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
     */
    func recursiveA11yDescription(isTopLevel: Bool = true) -> [String] {
        let children = subviews.flatMap { $0.recursiveA11yDescription(isTopLevel: false) }
        if children.isEmpty && !self.isAccessibilityElement && !isTopLevel {
            return []
        }
        let namePrefix = isHidden ? "o" : "*"
        var result = ["\(namePrefix) \(String(reflecting: Self.self))"]
        let childPrefix: String
            = isHidden ? "o "
            : isAccessibilityElement ? "| "
            : "  "
        if self.isAccessibilityElement {
            result.append(
                contentsOf: [
                    accessibilityValue.map { "\(childPrefix)-value: \($0)" },
                    accessibilityLabel.map { "\(childPrefix)-label: \($0)" },
                    accessibilityHint.map { "\(childPrefix)-hint: \($0)" },
                    "\(childPrefix)-traits: \(accessibilityTraits)"
                ].compactMap { $0 })
            result.append(contentsOf: (accessibilityCustomActions ?? [])
                .map { "\(childPrefix)-action: \($0.name)" })
        }
        result.append(contentsOf: children.map { childPrefix + $0 })
        return result
    }
}

extension Snapshotting where Value == UIView, Format == String {
    public static var recursiveA11yDescription: Snapshotting {
        return Snapshotting.recursiveA11yDescription()
    }

    public static func recursiveA11yDescription(
      size: CGSize? = nil,
      traits: UITraitCollection = .init()
      )
      -> Snapshotting<UIView, String> {
        enableAccessibility()
        return SimplySnapshotting.lines.pullback { view in
            let description = view.recursiveA11yDescription()
            return purgeUnknownContexts(description.joined(separator: "\n"))
        }
    }

    /* Clean up this sort of thing: MDViewLayer.(unknown context at $10d69dd68).ProceedButton
     * which otherwise includes a reference (memory location? file+line hash?) which is not stable.
     */
    internal static func purgeUnknownContexts(_ string: String) -> String {
        string.replacingOccurrences(
            of: "[(]unknown context at \\$[\\da-f]+[)]",
            with: "(unknown context)",
            options: .regularExpression)
    }
}

/*
 Awful hack Swiftified from
 https://github.com/cashapp/AccessibilitySnapshot/blob/9b1a71d30bd8e1df7d18ceb98a108cadb3841e26/AccessibilitySnapshot/Core/Classes/ASAccessibilityEnabler.m
 (thanks to Bruno Scheele for the pointer).
 This uses private API so we cannot expect it to continue to work forever, but if it fails
 it will fail very prominently so that's not a problem (and of course it isn't included in
 the release binary).
 */
func enableAccessibility() {
    guard
        let handle = loadDylibInSimulator(name: "/usr/lib/libAccessibility.dylib"),
        let _AXSSetAutomationEnabled = dlsym(handle, "_AXSSetAutomationEnabled")
        else { fatalError("sad trombone") }
    let AXSSetAutomationEnabled = unsafeBitCast(
        _AXSSetAutomationEnabled, to: (@convention(c) (CInt) -> Void).self)
    AXSSetAutomationEnabled(1)
}

func loadDylibInSimulator(name: String) -> UnsafeMutableRawPointer? {
    let environment = ProcessInfo.processInfo.environment
    guard let simulatorRoot = environment["IPHONE_SIMULATOR_ROOT"] else { return nil }
    let url = URL(fileURLWithPath: simulatorRoot).appendingPathComponent(name)
    let cString = FileManager.default.fileSystemRepresentation(withPath: url.path)
    return dlopen(cString, RTLD_LOCAL)
}

extension UIAccessibilityTraits: CustomDebugStringConvertible {
    public var debugDescription: String {
        let traits = [
            (UIAccessibilityTraits.adjustable, ".adjustable"),
            (.allowsDirectInteraction, ".allowsDirectInteraction"),
            (.button, ".button"),
            (.causesPageTurn, ".causesPageTurn"),
            (.header, ".header"),
            (.image, ".image"),
            (.keyboardKey, ".keyboardKey"),
            (.link, ".link"),
            (.notEnabled, ".notEnabled"),
            (.playsSound, ".playsSound"),
            (.searchField, ".searchField"),
            (.selected, ".selected"),
            (.startsMediaSession, ".startsMediaSession"),
            (.staticText, ".staticText"),
            (.summaryElement, ".summaryElement"),
            (.tabBar, ".tabBar"),
            (.updatesFrequently, ".updatesFrequently")
            ]
            .filter { self.contains($0.0) }
            .map { $0.1 }
        return traits.isEmpty ? ".none" : traits.joined(separator: ", ")
    }
}
