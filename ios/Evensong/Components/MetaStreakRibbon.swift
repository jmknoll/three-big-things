import SwiftUI

struct MetaStreakRibbon: View {
    let current: Int
    let longest: Int

    var body: some View {
        HStack(spacing: Space.xs) {
            Image(systemName: "flame")
                .imageScale(.small)
            Text(ribbonText)
        }
        .font(.footnote)
        .foregroundStyle(Color.stone)
        .accessibilityLabel(ribbonText)
    }

    private var ribbonText: String {
        if current == 0 {
            return "Start your streak today."
        } else if current == 1 {
            return "1 day streak."
        } else if current >= longest && longest > 1 {
            return "\(current) day streak — your best yet."
        } else {
            return "\(current) day streak."
        }
    }
}
