import SwiftUI

struct MilestoneDetailSheet: View {
    let milestone: Milestone?
    let projectId: String
    @EnvironmentObject var detailVM: ProjectDetailViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var startDate: Date?
    @State private var targetDate: Date?
    @State private var status: MilestoneStatus = .active
    @State private var showStartPicker = false
    @State private var showTargetPicker = false
    @State private var showDeleteConfirm = false
    @State private var isLoading = false

    var isCreating: Bool { milestone == nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Milestone name", text: $name)
                    TextField("Description (optional)", text: $description)
                }

                Section("Dates") {
                    datePicker(label: "Start date", date: $startDate, showing: $showStartPicker)
                    datePicker(label: "Target date", date: $targetDate, showing: $showTargetPicker)
                }

                if !isCreating {
                    Section("Status") {
                        Picker("Status", selection: $status) {
                            Text("In Progress").tag(MilestoneStatus.active)
                            Text("Complete").tag(MilestoneStatus.complete)
                            Text("Skipped").tag(MilestoneStatus.skipped)
                        }
                        .pickerStyle(.segmented)
                    }

                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Text("Delete milestone")
                        }
                    }
                }
            }
            .navigationTitle(isCreating ? "New Milestone" : "Edit Milestone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isCreating ? "Add" : "Save") {
                        Task { await save() }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                }
            }
            .confirmationDialog("Delete milestone?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    Task {
                        if let id = milestone?.id {
                            await detailVM.deleteMilestone(id)
                        }
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Goals attached to this milestone will remain, but will no longer be linked to it.")
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear { populate() }
    }

    @ViewBuilder
    private func datePicker(label: String, date: Binding<Date?>, showing: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(label)
                Spacer()
                if let d = date.wrappedValue {
                    Button(d.isoDateString) { showing.wrappedValue.toggle() }
                        .foregroundStyle(Color.indigo)
                        .font(.callout)
                } else {
                    Button("Set") { showing.wrappedValue = true }
                        .foregroundStyle(Color.fog)
                }
            }
            if showing.wrappedValue {
                DatePicker("", selection: Binding(
                    get: { date.wrappedValue ?? Date() },
                    set: { date.wrappedValue = $0 }
                ), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .transition(.opacity)
            }
        }
        .animation(.standard, value: showing.wrappedValue)
    }

    private func populate() {
        guard let ms = milestone else { return }
        name = ms.name
        description = ms.description ?? ""
        status = ms.status
        if let s = ms.startDate { startDate = Date.from(isoDate: s) }
        if let t = ms.targetDate { targetDate = Date.from(isoDate: t) }
    }

    private func save() async {
        isLoading = true
        defer { isLoading = false }
        let draft = MilestoneDraft(
            name: name.trimmingCharacters(in: .whitespaces),
            description: description,
            startDate: startDate,
            targetDate: targetDate,
            status: status
        )
        if let ms = milestone {
            await detailVM.updateMilestone(ms.id, draft: draft)
        } else {
            await detailVM.addMilestone(draft)
        }
        dismiss()
    }
}
