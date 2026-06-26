import SwiftUI

enum GoalCardMode {
    case entry(draft: Binding<GoalDraft>, slot: Int)
    case read(goal: DailyGoal)
    case checkin(goal: DailyGoal, checkIn: Binding<GoalCheckIn>)
}

struct GoalCard: View {
    let mode: GoalCardMode
    @EnvironmentObject var projectsVM: ProjectsViewModel
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            switch mode {
            case .entry(let draft, let slot):
                entryContent(draft: draft, slot: slot)
            case .read(let goal):
                readContent(goal: goal)
            case .checkin(let goal, let ci):
                checkinContent(goal: goal, checkIn: ci)
            }
        }
        .padding(.horizontal, Space.lg)
        .padding(.vertical, 14)
        .background(Color.surface)
        .cornerRadius(14)
        .shadow(color: .black.opacity(colorScheme == .light ? 0.06 : 0), radius: 8, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(colorScheme == .dark ? Color.mist : .clear, lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
    }

    // MARK: - Entry Mode

    @ViewBuilder
    private func entryContent(draft: Binding<GoalDraft>, slot: Int) -> some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            TextField("Goal \(slot)", text: draft.text, axis: .vertical)
                .font(.body)
                .foregroundStyle(Color.ink)
                .focused($isFocused)
                .lineLimit(3...6)

            if draft.wrappedValue.text.count > 100 {
                HStack {
                    Spacer()
                    Text("\(draft.wrappedValue.text.count)/120")
                        .font(.footnote)
                        .foregroundStyle(draft.wrappedValue.text.count > 120 ? Color.amber : Color.stone)
                }
            }

            AssignmentPill(assignment: draft.assignment)
                .environmentObject(projectsVM)
        }
        .accessibilityLabel("Goal \(slot)\(draft.wrappedValue.text.isEmpty ? "" : ", \(draft.wrappedValue.text)")")
    }

    // MARK: - Read Mode

    @ViewBuilder
    private func readContent(goal: DailyGoal) -> some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            HStack(alignment: .top) {
                Text(goal.text)
                    .font(.headline)
                    .foregroundStyle(Color.ink)
                Spacer()
                StatusChip(mode: .badge(status: goal.status))
            }

            if let project = goal.project {
                readProjectRow(project: project, milestone: goal.milestone)
            }

            if goal.carryForwardOf != nil {
                carryForwardBadge
            }
        }
    }

    // MARK: - Check-In Mode

    @ViewBuilder
    private func checkinContent(goal: DailyGoal, checkIn: Binding<GoalCheckIn>) -> some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            Text(goal.text)
                .font(.headline)
                .foregroundStyle(Color.ink)

            if let project = goal.project {
                readProjectRow(project: project, milestone: goal.milestone)
            }

            StatusChip(mode: .selection(status: Binding(
                get: { checkIn.wrappedValue.status == .pending ? nil : checkIn.wrappedValue.status },
                set: { checkIn.wrappedValue.status = $0 ?? .pending }
            )))

            if checkIn.wrappedValue.status != .pending {
                VStack(alignment: .leading, spacing: Space.xs) {
                    TextField("Add a note (optional)", text: checkIn.noteText, axis: .vertical)
                        .font(.body)
                        .foregroundStyle(Color.ink)
                        .lineLimit(2...4)

                    Toggle(isOn: checkIn.carryForward) {
                        Label("Carry forward to tomorrow", systemImage: "arrow.uturn.right")
                            .font(.callout)
                            .foregroundStyle(Color.amber)
                    }
                    .tint(Color.amber)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.standard, value: checkIn.wrappedValue.status)
    }

    // MARK: - Shared Sub-views

    @ViewBuilder
    private func readProjectRow(project: ProjectRef, milestone: MilestoneRef?) -> some View {
        HStack(spacing: Space.xs) {
            Circle()
                .fill(project.color.color)
                .frame(width: 7, height: 7)
            Text(project.name)
                .foregroundStyle(Color.stone)
            if let m = milestone {
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundStyle(Color.fog)
                Text(m.name)
                    .foregroundStyle(Color.stone)
            }
        }
        .font(.subheadline)
        .lineLimit(1)
    }

    private var carryForwardBadge: some View {
        HStack(spacing: Space.xs) {
            Image(systemName: "arrow.uturn.right")
                .imageScale(.small)
            Text("Carried from yesterday")
        }
        .font(.caption)
        .foregroundStyle(Color.amber)
        .transition(.scale(scale: 0.7).combined(with: .opacity))
    }
}
