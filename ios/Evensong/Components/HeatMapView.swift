import SwiftUI

struct HeatMapView: View {
    let activity: [ActivityEntry]
    let color: ProjectColor
    var isCompact: Bool = false

    private var activityDict: [String: ActivityEntry] {
        Dictionary(uniqueKeysWithValues: activity.map { ($0.date, $0) })
    }

    var body: some View {
        if isCompact {
            compactView
        } else {
            expandedView
        }
    }

    // MARK: - Compact (30 squares, 6pt, project card)

    private var compactView: some View {
        let days = last30Days()
        return HStack(spacing: 2) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                let isoDate = date.isoDateString
                let entry = activityDict[isoDate]
                compactSquare(entry: entry, index: index)
                    .frame(width: 6, height: 6)
            }
        }
        .accessibilityHidden(true)
    }

    private func compactSquare(entry: ActivityEntry?, index: Int) -> some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(squareColor(entry: entry))
    }

    // MARK: - Expanded (8pt, project detail)

    private var expandedView: some View {
        let days = last90Days()
        let weeks = stride(from: 0, to: days.count, by: 7).map { Array(days[$0..<min($0 + 7, days.count)]) }
        return HStack(alignment: .top, spacing: 3) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { wIndex, week in
                VStack(spacing: 3) {
                    ForEach(Array(week.enumerated()), id: \.offset) { dIndex, date in
                        let isoDate = date.isoDateString
                        let entry = activityDict[isoDate]
                        RoundedRectangle(cornerRadius: 2)
                            .fill(squareColor(entry: entry))
                            .frame(width: 8, height: 8)
                            .animation(
                                .easeOut(duration: 0.3).delay(Double(wIndex * 7 + dIndex) * 0.008),
                                value: true
                            )
                            .accessibilityLabel(squareAccessibilityLabel(date: date, entry: entry))
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func squareColor(entry: ActivityEntry?) -> Color {
        guard let entry, entry.goalsSet > 0 else { return Color.mist }
        let ratio = Double(entry.goalsCompleted) / Double(entry.goalsSet)
        if ratio >= 1.0 { return color.color.opacity(0.8) }
        if ratio >= 0.5 { return color.color.opacity(0.6) }
        return color.color.opacity(0.25)
    }

    private func squareAccessibilityLabel(date: Date, entry: ActivityEntry?) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        let dateStr = fmt.string(from: date)
        guard let e = entry, e.goalsSet > 0 else { return "\(dateStr), no goals" }
        return "\(dateStr), \(e.goalsSet) goals set, \(e.goalsCompleted) completed"
    }

    private func last30Days() -> [Date] {
        (0..<30).reversed().compactMap {
            Calendar.current.date(byAdding: .day, value: -$0, to: Date.today)
        }
    }

    private func last90Days() -> [Date] {
        (0..<90).reversed().compactMap {
            Calendar.current.date(byAdding: .day, value: -$0, to: Date.today)
        }
    }
}
