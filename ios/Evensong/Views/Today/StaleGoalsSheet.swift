import SwiftUI

struct StaleGoalsSheet: View {
    let staleGoals: [DailyGoal]
    let continuation: TodayStateContinuation
    @EnvironmentObject var viewModel: TodayViewModel
    @EnvironmentObject var projectsVM: ProjectsViewModel

    @State private var checkIns: [GoalCheckIn]

    init(staleGoals: [DailyGoal], continuation: TodayStateContinuation) {
        self.staleGoals = staleGoals
        self.continuation = continuation
        self._checkIns = State(initialValue: staleGoals.map {
            GoalCheckIn(goalId: $0.id, status: .pending)
        })
    }

    private var canResolve: Bool {
        checkIns.allSatisfy { $0.status != .pending }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.xl2) {
                    VStack(alignment: .leading, spacing: Space.xs) {
                        Text("Unresolved goals from yesterday")
                            .font(.title2.bold())
                            .foregroundStyle(Color.ink)
                        Text("Choose what happened with each one before setting today's intentions.")
                            .font(.subheadline)
                            .foregroundStyle(Color.stone)
                    }
                    .padding(.horizontal, Space.xl)

                    VStack(spacing: Space.md) {
                        ForEach(Array(staleGoals.enumerated()), id: \.element.id) { index, goal in
                            GoalCard(mode: .checkin(goal: goal, checkIn: checkInBinding(index)))
                                .environmentObject(projectsVM)
                        }
                    }
                    .padding(.horizontal, Space.xl)

                    CTAButton(title: "Resolve", isEnabled: canResolve) {
                        await viewModel.resolveStale(checkIns, continuation: continuation)
                    }
                    .padding(.horizontal, Space.xl)
                    .padding(.bottom, Space.xl2)
                }
                .padding(.top, Space.xl)
            }
            .background(Color.canvas.ignoresSafeArea())
            .navigationTitle("Yesterday's goals")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled(true)
    }

    private func checkInBinding(_ index: Int) -> Binding<GoalCheckIn> {
        Binding(
            get: { checkIns[index] },
            set: { checkIns[index] = $0 }
        )
    }
}
