import SwiftUI

struct ProjectEditSheet: View {
    let project: Project?
    @EnvironmentObject var projectsVM: ProjectsViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var targetQuarter = ""
    @State private var selectedColor: ProjectColor = .fern
    @State private var showArchiveConfirm = false
    @State private var isLoading = false
    @State private var error: String?

    var isCreating: Bool { project == nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Project name") {
                    TextField("Name", text: $name)
                }

                Section("Details") {
                    TextField("Description (optional)", text: $description)
                    TextField("Target quarter (e.g. Q2 2026)", text: $targetQuarter)
                }

                Section("Color") {
                    HStack(spacing: Space.md) {
                        ForEach(ProjectColor.allCases, id: \.rawValue) { color in
                            ZStack {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 36, height: 36)
                                if selectedColor == color {
                                    Image(systemName: "checkmark")
                                        .font(.caption.bold())
                                        .foregroundStyle(.white)
                                }
                            }
                            .onTapGesture { selectedColor = color }
                            .accessibilityLabel(color.displayName)
                        }
                    }
                    .padding(.vertical, Space.xs)
                }

                if !isCreating {
                    Section {
                        Button(role: .destructive) {
                            showArchiveConfirm = true
                        } label: {
                            Label("Archive project", systemImage: "archivebox")
                        }
                    }
                }

                if let error {
                    Section {
                        Text(error)
                            .foregroundStyle(Color.amber)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(isCreating ? "New Project" : (project?.name ?? "Edit Project"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await save() }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                }
            }
            .confirmationDialog("Archive project?", isPresented: $showArchiveConfirm) {
                Button("Archive", role: .destructive) {
                    Task {
                        if let id = project?.id {
                            await projectsVM.archive(id)
                        }
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Goals and milestones will be kept. You can unarchive at any time.")
            }
        }
        .presentationDetents([.large])
        .onAppear { populate() }
    }

    private func populate() {
        guard let p = project else { return }
        name = p.name
        description = p.description ?? ""
        targetQuarter = p.targetQuarter ?? ""
        selectedColor = p.color
    }

    private func save() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        let draft = ProjectDraft(
            name: name.trimmingCharacters(in: .whitespaces),
            color: selectedColor,
            description: description,
            targetQuarter: targetQuarter
        )
        if let p = project {
            await projectsVM.update(p.id, draft: draft)
        } else {
            _ = await projectsVM.create(draft)
        }
        if projectsVM.error == nil {
            dismiss()
        } else {
            error = projectsVM.error
            projectsVM.error = nil
        }
    }
}
