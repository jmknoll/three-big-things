import SwiftUI

struct EveningCheckInView: View {
    let goals: [DailyGoal]
    @EnvironmentObject var viewModel: TodayViewModel
    @EnvironmentObject var projectsVM: ProjectsViewModel

    @State private var checkIns: [GoalCheckIn]
    @State private var showCompletion = false

    init(goals: [DailyGoal]) {
        self.goals = goals
        self._checkIns = State(initialValue: goals.map {
            GoalCheckIn(goalId: $0.id, status: .pending)
        })
    }

    private var canSubmit: Bool {
        checkIns.allSatisfy { $0.status != .pending }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.xl2) {
                    VStack(alignment: .leading, spacing: Space.xs) {
                        Text("How did today go?")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color.ink)
                    }
                    .padding(.horizontal, Space.xl)

                    VStack(spacing: Space.md) {
                        ForEach(Array(goals.enumerated()), id: \.element.id) { index, goal in
                            GoalCard(mode: .checkin(goal: goal, checkIn: checkInBinding(index)))
                                .environmentObject(projectsVM)
                        }
                    }
                    .padding(.horizontal, Space.xl)

                    CTAButton(title: "Complete check-in", isEnabled: canSubmit) {
                        await submit()
                    }
                    .padding(.horizontal, Space.xl)
                    .padding(.bottom, Space.xl2)
                }
                .padding(.top, Space.xl)
            }
            .background(Color.canvas.ignoresSafeArea())

            if showCompletion {
                Color.sage.opacity(0.12)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }
        }
        .animation(.completionFlash, value: showCompletion)
    }

    private func checkInBinding(_ index: Int) -> Binding<GoalCheckIn> {
        Binding(
            get: { checkIns[index] },
            set: { checkIns[index] = $0 }
        )
    }

    private func submit() async {
        withAnimation(.completionFlash) { showCompletion = true }
        await viewModel.submitCheckIn(checkIns)
        try? await Task.sleep(nanoseconds: 500_000_000)
        withAnimation { showCompletion = false }
    }
}
