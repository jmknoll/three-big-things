import SwiftUI

struct AssignmentSheet: View {
    @Binding var selection: Assignment?
    @EnvironmentObject var projectsVM: ProjectsViewModel
    @EnvironmentObject var router: AppRouter
    @Environment(\.dismiss) var dismiss
    @State private var expandedProjectId: String?

    var body: some View {
        NavigationStack {
            List {
                if projectsVM.activeProjects.count >= 4 {
                    Section {
                        HStack(spacing: Space.sm) {
                            Label("You have \(projectsVM.activeProjects.count) active projects. Fewer tends to work better.", systemImage: "info.circle")
                                .font(.footnote)
                                .foregroundStyle(Color.amber)
                            Spacer(minLength: Space.sm)
                            Button("Manage") {
                                router.selectedTab = .projects
                                dismiss()
                            }
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.amber)
                        }
                    }
                    .listRowBackground(Color.amber.opacity(0.08))
                }

                ForEach(projectsVM.activeProjects) { project in
                    projectRow(project)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Assign to project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.fraction(0.55)])
        .task { await projectsVM.loadActive() }
    }

    @ViewBuilder
    private func projectRow(_ project: Project) -> some View {
        let isExpanded = expandedProjectId == project.id
        let isSelected = selection?.project.id == project.id && selection?.milestone == nil

        Section {
            // Project row
            Button {
                select(project: project, milestone: nil)
            } label: {
                HStack(spacing: Space.md) {
                    Circle()
                        .fill(project.color.color)
                        .frame(width: 10, height: 10)
                    Text(project.name)
                        .font(.body)
                        .foregroundStyle(Color.ink)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.sage)
                    }
                    if !(project.milestones?.isEmpty ?? true) {
                        Button {
                            withAnimation(.standard) {
                                expandedProjectId = isExpanded ? nil : project.id
                            }
                        } label: {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundStyle(Color.fog)
                                .imageScale(.small)
                        }
                    }
                }
            }
            .listRowBackground(Color.surface)

            // Milestone rows (expanded)
            if isExpanded, let milestones = project.milestones {
                ForEach(milestones.filter { $0.status == .active }) { ms in
                    Button {
                        select(project: project, milestone: ms)
                    } label: {
                        HStack(spacing: Space.md) {
                            Spacer().frame(width: 22)
                            Text(ms.name)
                                .font(.callout)
                                .foregroundStyle(Color.slate)
                            Spacer()
                            if selection?.milestone?.id == ms.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.sage)
                            }
                        }
                    }
                    .listRowBackground(Color.surface)
                }
            }
        }
    }

    private func select(project: Project, milestone: Milestone?) {
        HapticManager.soft()
        let ref = ProjectRef(id: project.id, name: project.name, color: project.color)
        let msRef = milestone.map { MilestoneRef(id: $0.id, name: $0.name) }
        selection = Assignment(project: ref, milestone: msRef)
        Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            dismiss()
        }
    }
}
