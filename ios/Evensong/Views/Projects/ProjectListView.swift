import SwiftUI

struct ProjectListView: View {
    @EnvironmentObject var projectsVM: ProjectsViewModel
    @State private var showCreateSheet = false
    @State private var showSoftLimitAlert = false

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
                            showSoftLimitAlert = true
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
            .confirmationDialog(
                "You have \(projectsVM.activeProjects.count) active projects.",
                isPresented: $showSoftLimitAlert,
                titleVisibility: .visible
            ) {
                Button("Add another project") { showCreateSheet = true }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Keeping to 3 or fewer helps you stay focused.")
            }
            .sheet(isPresented: $showCreateSheet) {
                ProjectEditSheet(project: nil)
                    .environmentObject(projectsVM)
            }
        }
        .task { await projectsVM.loadActive() }
    }
}
