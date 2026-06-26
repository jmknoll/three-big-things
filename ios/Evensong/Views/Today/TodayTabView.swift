import SwiftUI

struct TodayTabView: View {
    @EnvironmentObject var viewModel: TodayViewModel
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var projectsVM: ProjectsViewModel
    @State private var showToast = false

    var body: some View {
        ZStack(alignment: .bottom) {
            mainContent
                .onChange(of: viewModel.toast) { _, newValue in
                    if newValue != nil {
                        showToast = true
                    }
                }

            if showToast, let msg = viewModel.toast {
                ToastView(message: msg, isShowing: $showToast)
                    .onChange(of: showToast) { _, showing in
                        if !showing { viewModel.toast = nil }
                    }
            }
        }
        .task {
            await loadIfNeeded()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task { await loadIfNeeded() }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.canvas)

        case .morningEntry(let prefills):
            MorningEntryView(prefills: prefills)
                .environmentObject(viewModel)
                .environmentObject(projectsVM)

        case .readView(let goals), .complete(let goals):
            TodayReadView(goals: goals)

        case .eodCheckIn(let goals):
            EveningCheckInView(goals: goals)
                .environmentObject(viewModel)

        case .staleResolution(let stale, let continuation):
            TodayReadView(goals: [])
                .sheet(isPresented: .constant(true)) {
                    StaleGoalsSheet(staleGoals: stale, continuation: continuation)
                        .environmentObject(viewModel)
                        .environmentObject(projectsVM)
                }
        }
    }

    private func loadIfNeeded() async {
        guard let user = auth.user else { return }
        await auth.refreshUser()
        if let refreshed = auth.user {
            await viewModel.refresh(user: refreshed)
        }
    }
}
