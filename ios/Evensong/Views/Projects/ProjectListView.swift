import SwiftUI

struct ProjectListView: View {
    @EnvironmentObject var projectsVM: ProjectsViewModel
    @State private var showCreateSheet = false
    @State private var showSoftLimitSheet = false
    @State private var continueToCreate = false

    var body: some View {
        NavigationStack {
            List {
                // Active projects
                Section {
                    ForEach(projectsVM.activeProjects) { project in
                        NavigationLink {
                            ProjectDetailView(project: project)
                                .environmentObject(projectsVM)
                        } label: {
                            ProjectCard(project: project)
                                .padding(.vertical, 2)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.canvas)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    }
                    .onMove { indices, newOffset in
                        projectsVM.activeProjects.move(fromOffsets: indices, toOffset: newOffset)
                        let ids = projectsVM.activeProjects.map { $0.id }
                        Task { await projectsVM.reorder(ids) }
                    }
                }

                if projectsVM.activeProjects.isEmpty {
                    Section {
                        VStack(spacing: Space.md) {
                            Text("Add a project to begin\nsetting goals.")
                                .font(.body)
                                .foregroundStyle(Color.stone)
                                .multilineTextAlignment(.center)
                            Button("Create your first project") {
                                showCreateSheet = true
                            }
                            .foregroundStyle(Color.sage)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Space.xl3)
                        .listRowBackground(Color.canvas)
                        .listRowSeparator(.hidden)
                    }
                }

                // Archived section
                if !projectsVM.archivedProjects.isEmpty || projectsVM.showArchived {
                    Section {
                        Button {
                            withAnimation(.standard) { projectsVM.showArchived.toggle() }
                            if projectsVM.showArchived && projectsVM.archivedProjects.isEmpty {
                                Task { await projectsVM.loadArchived() }
                            }
                        } label: {
                            HStack {
                                Text("Archived")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.stone)
                                Spacer()
                                Image(systemName: projectsVM.showArchived ? "chevron.up" : "chevron.down")
                                    .imageScale(.small)
                                    .foregroundStyle(Color.fog)
                            }
                        }
                        .listRowBackground(Color.canvas)
                        .listRowSeparator(.hidden)

                        if projectsVM.showArchived {
                            ForEach(projectsVM.archivedProjects) { project in
                                NavigationLink {
                                    ProjectDetailView(project: project)
                                        .environmentObject(projectsVM)
                                } label: {
                                    ProjectCard(project: project)
                                        .padding(.vertical, 2)
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.canvas)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .background(Color.canvas)
            .scrollContentBackground(.hidden)
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if projectsVM.activeProjects.count >= 3 {
                            showSoftLimitSheet = true
                        } else {
                            showCreateSheet = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.indigo)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .foregroundStyle(Color.indigo)
                }
            }
            // Soft-limit nudge (§5.3.1). We're already on the Projects tab, so
            // "Review active projects" just dismisses. Presenting the create sheet
            // is deferred to onDismiss so two sheets never contend for presentation.
            .sheet(isPresented: $showSoftLimitSheet, onDismiss: {
                if continueToCreate {
                    continueToCreate = false
                    showCreateSheet = true
                }
            }) {
                SoftLimitSheet(
                    count: projectsVM.activeProjects.count,
                    onReview: {},
                    onContinue: { continueToCreate = true }
                )
            }
            .sheet(isPresented: $showCreateSheet) {
                ProjectEditSheet(project: nil)
                    .environmentObject(projectsVM)
            }
        }
        .task { await projectsVM.loadActive() }
    }
}

/// The calm soft-limit prompt from PRD §5.3.1 — shown before new-project creation
/// when the user already has 3+ active projects. A gentle reminder, never a gate.
struct SoftLimitSheet: View {
    let count: Int
    let onReview: () -> Void
    let onContinue: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: Space.xl) {
            Text("You have \(count) active projects")
                .font(.title2.weight(.semibold))
                .foregroundStyle(Color.ink)

            Text("Keeping focus on a smaller number tends to make daily goal-setting more meaningful. Want to archive one first, or continue adding a new project?")
                .font(.body)
                .foregroundStyle(Color.stone)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: Space.sm) {
                CTAButton(title: "Review active projects", isEnabled: true) {
                    onReview()
                    dismiss()
                }
                Button("Continue anyway") {
                    onContinue()
                    dismiss()
                }
                .font(.callout.weight(.semibold))
                .foregroundStyle(Color.stone)
                .padding(.vertical, Space.sm)
            }
        }
        .padding(Space.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.canvas)
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.visible)
    }
}
