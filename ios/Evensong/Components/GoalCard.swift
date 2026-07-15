import SwiftUI

enum GoalCardMode {
    case entry(draft: Binding<GoalDraft>, slot: Int)
    case read(goal: DailyGoal)
    case checkin(goal: DailyGoal, checkIn: Binding<GoalCheckIn>)
}

/// Focus key for the three morning-entry slots, owned by `MorningEntryView`
/// so focus can be chained across cards (Return advances 1 → 2 → 3).
enum GoalField: Hashable {
    case slot(Int)
}

struct GoalCard: View {
    let mode: GoalCardMode
    /// Shared focus binding for entry-mode chaining. Nil in read/check-in modes.
    var focus: FocusState<GoalField?>.Binding? = nil
    @EnvironmentObject var projectsVM: ProjectsViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    /// True when this specific entry slot currently holds focus.
    private var isEntryFocused: Bool {
        guard case .entry(_, let slot) = mode, let current = focus?.wrappedValue else { return false }
        return current == GoalField.slot(slot)
    }

    /// True when any slot is focused (so unfocused siblings compress).
    private var anySlotFocused: Bool { focus?.wrappedValue != nil }

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
        .padding(.vertical, entryVerticalPadding)
        .background(Color.surface)
        .cornerRadius(14)
        .shadow(color: .black.opacity(colorScheme == .light ? 0.06 : 0), radius: 8, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(colorScheme == .dark ? Color.mist : .clear, lineWidth: 1)
        )
        .animation(reduceMotion ? nil : .slotExpand, value: focus?.wrappedValue)
        .accessibilityElement(children: .contain)
    }

    /// Focused slot breathes open; unfocused siblings compress slightly. Neutral 14 when idle.
    private var entryVerticalPadding: CGFloat {
        guard case .entry = mode, anySlotFocused else { return 14 }
        return isEntryFocused ? 20 : 10
    }

    // MARK: - Entry Mode

    @ViewBuilder
    private func entryContent(draft: Binding<GoalDraft>, slot: Int) -> some View {
        VStack(alignment: .leading, spacing: Space.sm) {
            entryTextField(draft: draft, slot: slot)

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

    // The entry field is `axis: .vertical` so Return inserts a newline rather than
    // firing `.onSubmit`. We intercept the newline, strip it, and advance focus to
    // the next slot — keeping the multiline goal text while chaining focus 1 → 2 → 3.
    @ViewBuilder
    private func entryTextField(draft: Binding<GoalDraft>, slot: Int) -> some View {
        let field = TextField("Goal \(slot)", text: draft.text, axis: .vertical)
            .font(.body)
            .foregroundStyle(Color.ink)
            .lineLimit(isEntryFocused || !anySlotFocused ? 3...6 : 1...2)
            .onChange(of: draft.wrappedValue.text) { _, newValue in
                guard newValue.contains("\n") else { return }
                draft.wrappedValue.text = newValue.replacingOccurrences(of: "\n", with: "")
                advanceFocus(from: slot)
            }

        if let focus {
            field.focused(focus, equals: .slot(slot))
        } else {
            field
        }
    }

    /// Move focus to the next slot, or dismiss the keyboard after the last one.
    private func advanceFocus(from slot: Int) {
        guard let focus else { return }
        HapticManager.soft()
        focus.wrappedValue = slot < 3 ? .slot(slot + 1) : nil
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
