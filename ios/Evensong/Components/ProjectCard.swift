import SwiftUI

struct ProjectCard: View {
    let project: Project
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            // 4pt color bar
            Rectangle()
                .fill(project.color.color.opacity(project.status == .archived ? 0.4 : 1.0))
                .frame(width: 4)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: Space.sm) {
                HStack {
                    Text(project.name)
                        .font(.headline)
                        .foregroundStyle(Color.ink)
                        .opacity(project.status == .archived ? 0.6 : 1.0)
                    Spacer()
                    if let q = project.targetQuarter {
                        Text(q)
                            .font(.caption)
                            .foregroundStyle(Color.stone)
                    }
                }

                HeatMapView(activity: project.activity ?? [], color: project.color, isCompact: true)
            }
            .padding(.horizontal, Space.md)
            .padding(.vertical, Space.md)
        }
        .background(Color.surface)
        .cornerRadius(12)
        .shadow(color: .black.opacity(colorScheme == .light ? 0.05 : 0), radius: 6, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorScheme == .dark ? Color.mist : .clear, lineWidth: 1)
        )
        .opacity(project.status == .archived ? 0.7 : 1.0)
    }
}
