import SwiftUI

enum OnboardingStep {
    case createProject
    case notifications
}

struct OnboardingFlow: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var step: OnboardingStep = .createProject

    var body: some View {
        switch step {
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
