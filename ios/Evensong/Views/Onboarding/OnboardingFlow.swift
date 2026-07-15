import SwiftUI

enum OnboardingStep {
    case welcome
    case createProject
    case notifications
}

struct OnboardingFlow: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var step: OnboardingStep = .welcome

    var body: some View {
        switch step {
        case .welcome:
            OnboardingWelcomeView(onContinue: { step = .createProject })
        case .createProject:
            OnboardingProjectView(onContinue: { step = .notifications })
        case .notifications:
            OnboardingNotificationsView(onContinue: {
                Task { await completeOnboarding() }
            })
        }
    }

    private func completeOnboarding() async {
        struct Patch: Encodable { let onboardingDone: Bool }
        _ = try? await APIClient.shared.request(.patchMe, body: Patch(onboardingDone: true)) as User
        await auth.refreshUser()
    }
}

/// Onboarding step 1 (PRD §9.4): app name, one-line purpose, and "Get started".
/// Purely advances local state — no network call.
struct OnboardingWelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.canvas.ignoresSafeArea()

            VStack(alignment: .leading, spacing: Space.xl3) {
                Spacer()

                VStack(alignment: .leading, spacing: Space.md) {
                    Text("Evensong")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.ink)

                    Text("A daily practice of focused, purposeful progress. Three goals each morning, one quiet check-in each evening.")
                        .font(.body)
                        .foregroundStyle(Color.stone)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, Space.xl)

                Spacer()

                CTAButton(title: "Get started", isEnabled: true) {
                    onContinue()
                }
                .padding(.horizontal, Space.xl)
                .padding(.bottom, Space.xl2)
            }
        }
    }
}
