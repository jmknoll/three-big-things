import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var todayVM: TodayViewModel
    @StateObject private var projectsVM = ProjectsViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                TodayTabView()
                    .tabItem {
                        Label("Today", systemImage: "sun.max")
                    }
                    .environmentObject(todayVM)
                    .environmentObject(projectsVM)

                ProjectListView()
                    .tabItem {
                        Label("Projects", systemImage: "folder")
                    }
                    .environmentObject(projectsVM)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "slider.horizontal.3")
                    }
                    .environmentObject(projectsVM)
            }
            .tint(.sage)

            if auth.user?.emailConfirmed == false {
                UnconfirmedEmailBanner(email: auth.user?.email ?? "")
                    .environmentObject(auth)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.standard, value: auth.user?.emailConfirmed)
    }
}

struct UnconfirmedEmailBanner: View {
    let email: String
    @EnvironmentObject var auth: AuthViewModel
    @State private var didResend = false

    var body: some View {
        HStack(spacing: Space.sm) {
            Image(systemName: "envelope")
                .imageScale(.small)
                .foregroundStyle(Color.amber)
            Text("Confirm your email to secure your account.")
                .font(.footnote)
                .foregroundStyle(Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()
            Button(didResend ? "Sent" : "Resend") {
                guard !didResend else { return }
                didResend = true
                Task { await auth.resendConfirmation(email: email) }
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(didResend ? Color.stone : Color.amber)
            .disabled(didResend)
        }
        .padding(.horizontal, Space.lg)
        .padding(.vertical, Space.sm)
        .background(Color.amber.opacity(0.12))
    }
}
