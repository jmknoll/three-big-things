import SwiftUI

struct TodayReadView: View {
    let goals: [DailyGoal]
    @EnvironmentObject var projectsVM: ProjectsViewModel

    private var isAfterSix: Bool {
        Calendar.current.component(.hour, from: Date()) >= 18
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl2) {
                VStack(alignment: .leading, spacing: Space.xs) {
                    Text(Date().dayName)
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.ink)
                    Text("Today's intentions")
                        .font(.subheadline)
                        .foregroundStyle(Color.stone)
                }
                .padding(.horizontal, Space.xl)

                VStack(spacing: Space.md) {
                    ForEach(goals) { goal in
                        GoalCard(mode: .read(goal: goal))
                            .environmentObject(projectsVM)
                    }
                }
                .padding(.horizontal, Space.xl)

                if isAfterSix && goals.contains(where: { $0.status == .pending }) {
                    Text("Check in this evening →")
                        .font(.footnote)
                        .foregroundStyle(Color.stone)
                        .padding(.horizontal, Space.xl)
                        .transition(.opacity)
                }
            }
            .padding(.top, Space.xl)
            .padding(.bottom, Space.xl2)
        }
        .background(Color.canvas.ignoresSafeArea())
        .animation(.standard, value: isAfterSix)
    }
}
