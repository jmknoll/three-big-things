import SwiftUI

enum StatusChipMode {
    case selection(status: Binding<GoalStatus?>)
    case badge(status: GoalStatus)
}

struct StatusChip: View {
    let mode: StatusChipMode

    var body: some View {
        switch mode {
        case .selection(let binding):
            selectionChips(binding: binding)
        case .badge(let status):
            badgeChip(status: status)
        }
    }

    @ViewBuilder
    private func selectionChips(binding: Binding<GoalStatus?>) -> some View {
        HStack(spacing: Space.sm) {
            ForEach([GoalStatus.complete, .partial, .expired], id: \.rawValue) { status in
                selectionChip(status: status, selected: binding.wrappedValue == status) {
                    withAnimation(.standard) { binding.wrappedValue = status }
                    HapticManager.soft()
                }
            }
        }
    }

    @ViewBuilder
    private func selectionChip(status: GoalStatus, selected: Bool, action: @escaping () -> Void) -> some View {
        let label = chipLabel(status)
        Button(action: action) {
            Text(label)
                .font(.callout)
                .foregroundStyle(selected ? .white : Color.slate)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Space.sm)
                .background(selected ? chipColor(status) : Color.mist)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selected ? chipColor(status) : Color.clear, lineWidth: 1.5)
                )
        }
        .accessibilityLabel(label)
        .accessibilityHint("Mark goal as \(label)")
    }

    @ViewBuilder
    private func badgeChip(status: GoalStatus) -> some View {
        HStack(spacing: Space.xs) {
            Circle()
                .fill(chipColor(status))
                .frame(width: 6, height: 6)
            Text(chipLabel(status))
                .font(.caption)
                .foregroundStyle(chipColor(status))
        }
        .padding(.horizontal, Space.sm)
        .padding(.vertical, 3)
        .background(chipColor(status).opacity(0.12))
        .cornerRadius(6)
        .accessibilityLabel(chipLabel(status))
    }

    private func chipLabel(_ status: GoalStatus) -> String {
        switch status {
        case .pending:          return "Pending"
        case .complete:         return "Done"
        case .partial:          return "Partial"
        case .carried_forward:  return "Carried"
        case .expired:          return "Not today"
        }
    }

    private func chipColor(_ status: GoalStatus) -> Color {
        switch status {
        case .complete:         return .sage
        case .partial:          return .amber
        case .carried_forward:  return .amber
        case .expired:          return .stone
        case .pending:          return .fog
        }
    }
}
