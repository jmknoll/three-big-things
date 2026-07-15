import SwiftUI

struct AssignmentPill: View {
    @Binding var assignment: Assignment?
    @EnvironmentObject var projectsVM: ProjectsViewModel
    @EnvironmentObject var router: AppRouter
    @State private var showSheet = false

    var body: some View {
        Button { showSheet = true } label: {
            HStack(spacing: Space.xs) {
                if let a = assignment {
                    Circle()
                        .fill(a.project.color.color)
                        .frame(width: 8, height: 8)
                    Text(a.project.name)
                        .lineLimit(1)
                    if let m = a.milestone {
                        Image(systemName: "chevron.right")
                            .imageScale(.small)
                            .foregroundStyle(Color.fog)
                        Text(m.name)
                            .lineLimit(1)
                    }
                } else {
                    Image(systemName: "plus")
                        .imageScale(.small)
                    Text("Assign to project")
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundStyle(Color.fog)
            }
            .font(.callout)
            .foregroundStyle(assignment == nil ? Color.fog : Color.slate)
            .padding(.horizontal, Space.md)
            .padding(.vertical, Space.sm)
            .background(Color.mist.opacity(0.5))
            .cornerRadius(8)
        }
        .sheet(isPresented: $showSheet) {
            AssignmentSheet(selection: $assignment)
                .environmentObject(projectsVM)
                .environmentObject(router)
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Tap to assign project")
    }

    private var accessibilityLabel: String {
        guard let a = assignment else { return "Assign to project" }
        if let m = a.milestone {
            return "Assigned to \(a.project.name), \(m.name)"
        }
        return "Assigned to \(a.project.name)"
    }
}
