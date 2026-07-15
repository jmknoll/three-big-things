import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var projectsVM: ProjectsViewModel
    @EnvironmentObject var router: AppRouter
    @StateObject private var settingsVM = SettingsViewModel()

    @State private var morningTime: Date = defaultTime(hour: 8)
    @State private var eodTime: Date = defaultTime(hour: 20)
    @State private var showNotificationsExpanded = false
    @State private var showCreateProject = false
    @State private var showSoftLimitSheet = false
    @State private var continueToCreate = false
    @State private var editingProject: Project?

    var body: some View {
        NavigationStack {
            List {
                // Projects section
                Section("Active Projects") {
                    ForEach(projectsVM.activeProjects) { project in
                        Button {
                            editingProject = project
                        } label: {
                            HStack(spacing: Space.md) {
                                Circle()
                                    .fill(project.color.color)
                                    .frame(width: 10, height: 10)
                                Text(project.name)
                                    .foregroundStyle(Color.ink)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .imageScale(.small)
                                    .foregroundStyle(Color.fog)
                            }
                        }
                    }
                    Button {
                        if projectsVM.activeProjects.count >= 3 {
                            showSoftLimitSheet = true
                        } else {
                            showCreateProject = true
                        }
                    } label: {
                        Label("New project", systemImage: "plus")
                            .foregroundStyle(Color.indigo)
                    }
                }

                // Notifications section
                Section("Notifications") {
                    Toggle("Enable reminders", isOn: $settingsVM.notificationsEnabled)
                        .tint(Color.sage)
                        .onChange(of: settingsVM.notificationsEnabled) { _, enabled in
                            Task { await settingsVM.updateMe(notificationsEnabled: enabled) }
                        }

                    if settingsVM.notificationsEnabled {
                        timePickerRow(label: "Morning reminder", time: $morningTime) { time in
                            Task { await settingsVM.updateMe(morningTime: time.toHHMM()) }
                        }
                        timePickerRow(label: "Evening check-in", time: $eodTime) { time in
                            Task { await settingsVM.updateMe(eodTime: time.toHHMM()) }
                        }
                    }
                }

                // About section
                Section("About") {
                    HStack {
                        Text("Version")
                            .foregroundStyle(Color.ink)
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(Color.stone)
                    }
                    Link(destination: URL(string: "https://github.com/jamesonknoll")!) {
                        Label("Send feedback", systemImage: "envelope")
                            .foregroundStyle(Color.indigo)
                    }
                    Text("Evensong is a daily practice — not a productivity system. Three things, done with care.")
                        .font(.footnote)
                        .foregroundStyle(Color.stone)
                }

                Section {
                    Button(role: .destructive) {
                        auth.signOut()
                    } label: {
                        Text("Sign out")
                    }
                }
            }
            .navigationTitle("Settings")
            // Soft-limit nudge (§5.3.1). "Review active projects" jumps to the
            // Projects tab; creation is deferred to onDismiss to avoid sheet contention.
            .sheet(isPresented: $showSoftLimitSheet, onDismiss: {
                if continueToCreate {
                    continueToCreate = false
                    showCreateProject = true
                }
            }) {
                SoftLimitSheet(
                    count: projectsVM.activeProjects.count,
                    onReview: { router.selectedTab = .projects },
                    onContinue: { continueToCreate = true }
                )
            }
            .sheet(isPresented: $showCreateProject) {
                ProjectEditSheet(project: nil)
                    .environmentObject(projectsVM)
            }
            .sheet(item: $editingProject) { project in
                ProjectEditSheet(project: project)
                    .environmentObject(projectsVM)
            }
        }
        .onAppear {
            settingsVM.authViewModel = auth
            if let user = auth.user {
                morningTime = user.morningReminderTime.timeToday ?? defaultTime(hour: 8)
                eodTime = user.eodReminderTime.timeToday ?? defaultTime(hour: 20)
            }
        }
        .task { await projectsVM.loadActive() }
    }

    @ViewBuilder
    private func timePickerRow(label: String, time: Binding<Date>, onChange: @escaping (Date) -> Void) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(Color.ink)
            Spacer()
            DatePicker("", selection: time, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .onChange(of: time.wrappedValue) { _, newValue in
                    onChange(newValue)
                }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

private func defaultTime(hour: Int) -> Date {
    var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    comps.hour = hour; comps.minute = 0
    return Calendar.current.date(from: comps) ?? Date()
}

private extension Date {
    func toHHMM() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: self)
    }
}
