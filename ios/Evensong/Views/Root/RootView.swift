import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        Group {
            if auth.isLoading && auth.user == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.canvas)
            } else if let user = auth.user {
                if user.onboardingDone {
                    MainTabView()
                } else {
                    OnboardingFlow()
                }
            } else {
                LoginView()
            }
        }
        .animation(.standard, value: auth.user?.id)
    }
}
