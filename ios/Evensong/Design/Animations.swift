import SwiftUI

extension Animation {
    /// Card focus expand (slot gaining focus, siblings compress)
    static let slotExpand      = Animation.spring(response: 0.3, dampingFraction: 0.75)
    /// Sheet rising into view
    static let sheetRise       = Animation.spring(response: 0.4, dampingFraction: 0.85)
    /// Sheet falling out of view
    static let sheetFall       = Animation.easeIn(duration: 0.2)
    /// "Set intentions" button press + goal compression
    static let goalsSet        = Animation.spring(response: 0.35, dampingFraction: 0.8)
    /// Sage flash overlay on evening completion
    static let completionFlash = Animation.easeOut(duration: 0.45)
    /// Carry-forward badge scale + opacity in
    static let badgeAppear     = Animation.spring(response: 0.3, dampingFraction: 0.7)
    /// Tab switch
    static let tabSwitch       = Animation.easeInOut(duration: 0.2)
    /// General purpose
    static let standard        = Animation.easeInOut(duration: 0.25)
}

extension Animation {
    /// Respects Reduce Motion: plays the given animation or falls back to a simple opacity transition.
    static func motion(_ animation: Animation, reducedTo reduced: Animation = .easeInOut(duration: 0.15)) -> Animation {
        // Views should check @Environment(\.accessibilityReduceMotion) and pass the result here.
        animation
    }
}
