import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    @EnvironmentObject var projectsVM: ProjectsViewModel
    @StateObject private var detailVM: ProjectDetailViewModel
    @State private var showEditSheet = false
    @State private var showMilestoneSheet = false
    @State private var selectedMilestone: Milestone?

    init(project: Project) {
        self.project = project
        self._detailVM = StateObject(wrappedValue: ProjectDetailViewModel(project: project))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.xl2) {
                // Header
                projectHeader

                // Milestones
                milestonesSection

                // Activity heat map
                activitySection

                // Recent goals
                recentGoalsSection
            }
            .padding(.top, Space.xl)
            .padding(.bottom, Space.xl2)
        }
        .background(Color.canvas.ignoresSafeArea())
        .navigationTitle(detailVM.project.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if detailVM.project.status == .active {
                    Button("Edit") { showEditSheet = true }
                        .foregroundStyle(Color.indigo)
                } else {
                    Button("Unarchive") {
                        Task { await projectsVM.unarchive(project.id) }
                    }
                    .foregroundStyle(Color.indigo)
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            ProjectEditSheet(project: detailVM.project)
                .environmentObject(projectsVM)
        }
        .sheet(item: $selectedMilestone) { ms in
            MilestoneDetailSheet(milestone: ms, projectId: project.id)
                .environmentObject(detailVM)
        }
        .task { await detailVM.load() }
    }

    // MARK: - Sections

    private var projectHeader: some View {
        HStack(spacing: Space.md) {
            Rectangle()
                .fill(project.color.color)
                .frame(width: 4)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: Space.xs) {
                if let desc = detailVM.project.description {
                    Text(desc)
                        .font(.body)
                        .foregroundStyle(Color.slate)
                }
                if let q = detailVM.project.targetQuarter {
                    Text(q)
                        .font(.subheadline)
                        .foregroundStyle(Color.stone)
                }
                if detailVM.project.status == .archived {
                    Label("Archived", systemImage: "archivebox")
                        .font(.caption)
                        .foregroundStyle(Color.stone)
                }
            }
        }
        .padding(.horizontal, Space.xl)
    }

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            sectionHeader("Milestones") {
                Button {
                    showMilestoneSheet = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.indigo)
                }
            }

            if detailVM.milestones.isEmpty {
                Text("No milestones yet.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stone)
                    .padding(.horizontal, Space.xl)
            } else {
                VStack(spacing: 0) {
                    ForEach(detailVM.milestones) { ms in
                        MilestoneRow(milestone: ms) {
                            selectedMilestone = ms
                        }
                        .padding(.horizontal, Space.xl)
                        Divider().padding(.leading, Space.xl + 20 + Space.md)
                    }
                }
            }
        }
        .sheet(isPresented: $showMilestoneSheet) {
            MilestoneDetailSheet(milestone: nil, projectId: project.id)
                .environmentObject(detailVM)
        }
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            sectionHeader("Activity") { EmptyView() }
            HeatMapView(activity: detailVM.activity, color: project.color, isCompact: false)
                .padding(.horizontal, Space.xl)
        }
    }

    private var recentGoalsSection: some View {
        VStack(alignment: .leading, spacing: Space.md) {
            sectionHeader("Recent goals") { EmptyView() }
            if detailVM.recentGoals.isEmpty {
                Text("No recent goals for this project.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stone)
                    .padding(.horizontal, Space.xl)
            } else {
                let grouped = Dictionary(grouping: detailVM.recentGoals, by: { $0.date })
                let sortedDates = grouped.keys.sorted().reversed()
                ForEach(Array(sortedDates), id: \.self) { date in
                    VStack(alignment: .leading, spacing: Space.sm) {
                        Text(date)
                            .font(.caption)
                            .foregroundStyle(Color.stone)
                            .padding(.horizontal, Space.xl)
                        ForEach(grouped[date] ?? []) { goal in
                            HStack {
                                Text(goal.text)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.ink)
                                Spacer()
                                StatusChip(mode: .badge(status: goal.status))
                            }
                            .padding(.horizontal, Space.xl)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func sectionHeader<T: View>(_ title: String, @ViewBuilder trailing: () -> T) -> some View {
        HStack {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(Color.ink)
            Spacer()
            trailing()
        }
        .padding(.horizontal, Space.xl)
    }
}
