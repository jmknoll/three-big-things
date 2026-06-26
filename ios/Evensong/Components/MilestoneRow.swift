import SwiftUI

struct MilestoneRow: View {
    let milestone: Milestone
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: Space.md) {
                Image(systemName: statusIcon)
                    .foregroundStyle(statusColor)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(milestone.name)
                        .font(.body)
                        .foregroundStyle(Color.ink)
                        .lineLimit(2)

                    if let target = milestone.targetDate {
                        Text(target)
                            .font(.caption)
                            .foregroundStyle(Color.stone)
                    }
                }

                Spacer()

                statusBadge
            }
            .padding(.vertical, Space.sm)
        }
    }

    private var statusIcon: String {
        switch milestone.status {
        case .active:    return "circle"
        case .complete:  return "checkmark.circle.fill"
        case .skipped:   return "minus.circle"
        }
    }

    private var statusColor: Color {
        switch milestone.status {
        case .active:    return .indigo
        case .complete:  return .sage
        case .skipped:   return .stone
        }
    }

    private var statusBadge: some View {
        Text(milestone.status.rawValue.capitalized)
            .font(.caption)
            .foregroundStyle(statusColor)
            .padding(.horizontal, Space.sm)
            .padding(.vertical, 3)
            .background(statusColor.opacity(0.12))
            .cornerRadius(6)
    }
}
