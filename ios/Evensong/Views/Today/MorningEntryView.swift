import SwiftUI

struct MorningEntryView: View {
    let prefills: [DailyGoal]
    @EnvironmentObject var viewModel: TodayViewModel
    @EnvironmentObject var projectsVM: ProjectsViewModel

    @State private var drafts: [GoalDraft] = [GoalDraft(), GoalDraft(), GoalDraft()]
    @State private var isSubmitting = false

    private var canSubmit: Bool {
        drafts.allSatisfy { !$0.text.trimmingCharacters(in: .whitespaces).isEmpty && $0.assignment != nil }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl2) {
                header
                    .padding(.horizontal, Space.xl)

                if let user = viewModel.user {
                    MetaStreakRibbon(current: user.metaStreakCurrent, longest: user.metaStreakLongest)
                        .padding(.horizontal, Space.xl)
                }

                VStack(spacing: Space.md) {
                    ForEach(0..<3, id: \.self) { i in
                        GoalCard(mode: .entry(draft: $drafts[i], slot: i + 1))
                            .environmentObject(projectsVM)
                    }
                }
                .padding(.horizontal, Space.xl)

                CTAButton(title: "Set intentions", isEnabled: canSubmit && !isSubmitting) {
                    isSubmitting = true
                    await viewModel.submitGoals(drafts)
                    isSubmitting = false
                }
                .padding(.horizontal, Space.xl)
                .padding(.bottom, Space.xl2)
            }
            .padding(.top, Space.xl)
        }
        .background(Color.canvas.ignoresSafeArea())
        .onAppear { prefillDrafts() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Space.xs) {
            Text(Date().dayName)
                .font(.largeTitle.bold())
                .foregroundStyle(Color.ink)
            Text(Date().greetingTime)
                .font(.subheadline)
                .foregroundStyle(Color.stone)
        }
    }

    private func prefillDrafts() {
        for (index, goal) in prefills.prefix(3).enumerated() {
            drafts[index].text = goal.text
            if let project = goal.project {
                drafts[index].assignment = Assignment(
                    project: project,
                    milestone: goal.milestone
                )
            }
        }
    }
}
