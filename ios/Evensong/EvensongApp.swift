import SwiftUI
// import GoogleSignIn  // Commented out — re-enable when adding Google auth

@main
struct EvensongApp: App {
    @StateObject private var auth = AuthViewModel()
    @StateObject private var todayVM = TodayViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environmentObject(todayVM)
                // Re-enable when adding Google auth:
                // .onOpenURL { url in GIDSignIn.sharedInstance.handle(url) }
        }
    }
}
