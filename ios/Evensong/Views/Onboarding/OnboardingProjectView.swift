import SwiftUI

private struct CreateProjectBody: Encodable {
    let name: String
    let color: String
}

struct OnboardingProjectView: View {
    let onContinue: () -> Void

    @State private var name = ""
    @State private var selectedColor: ProjectColor = .fern
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        ZStack {
            Color.canvas.ignoresSafeArea()

            VStack(alignment: .leading, spacing: Space.xl3) {
                Spacer()

                VStack(alignment: .leading, spacing: Space.sm) {
                    Text("Start with something\nyou're working toward.")
                        .font(.title.bold())
                        .foregroundStyle(Color.ink)

                    Text("You can add more projects later.")
                        .font(.subheadline)
                        .foregroundStyle(Color.stone)
                }
                .padding(.horizontal, Space.xl)

                VStack(alignment: .leading, spacing: Space.lg) {
                    TextField("Project name", text: $name)
                        .font(.body)
                        .padding(Space.md)
                        .background(Color.surface)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.mist, lineWidth: 1)
                        )

                    HStack(spacing: Space.md) {
                        ForEach(ProjectColor.allCases, id: \.rawValue) { color in
                            colorSwatch(color)
                        }
                    }
                }
                .padding(.horizontal, Space.xl)

                if let error {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(Color.amber)
                        .padding(.horizontal, Space.xl)
                }

                Spacer()

                CTAButton(title: "Continue", isEnabled: !name.trimmingCharacters(in: .whitespaces).isEmpty && !isLoading) {
                    await createProject()
                }
                .padding(.horizontal, Space.xl)
                .padding(.bottom, Space.xl2)
            }
        }
    }

    @ViewBuilder
    private func colorSwatch(_ color: ProjectColor) -> some View {
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

    private func createProject() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            let body = CreateProjectBody(name: name.trimmingCharacters(in: .whitespaces), color: selectedColor.rawValue)
            let _: Project = try await APIClient.shared.request(.createProject, body: body)
            onContinue()
        } catch let e as APIError {
            error = e.localizedDescription
        } catch {
            self.error = error.localizedDescription
        }
    }
}
