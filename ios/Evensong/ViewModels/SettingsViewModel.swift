import SwiftUI

private struct UserPatch: Encodable {
    var morningReminderTime: String?
    var eodReminderTime: String?
    var notificationsEnabled: Bool?
    var onboardingDone: Bool?
    var timezoneOffset: Int?
}

@MainActor
class SettingsViewModel: ObservableObject {
    @AppStorage("morningTime") var morningTime: String = "08:00"
    @AppStorage("eodTime") var eodTime: String = "20:00"
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true

    weak var authViewModel: AuthViewModel?

    func updateMe(morningTime: String? = nil, eodTime: String? = nil, notificationsEnabled: Bool? = nil, onboardingDone: Bool? = nil) async {
        if let t = morningTime { self.morningTime = t }
        if let t = eodTime { self.eodTime = t }
        if let e = notificationsEnabled { self.notificationsEnabled = e }

        let patch = UserPatch(
            morningReminderTime: morningTime,
            eodReminderTime: eodTime,
            notificationsEnabled: notificationsEnabled,
            onboardingDone: onboardingDone
        )
        do {
            let _: User = try await APIClient.shared.request(.patchMe, body: patch)
            // Reschedule notifications if times changed
            if morningTime != nil || eodTime != nil {
                await NotificationManager.shared.scheduleAll(
                    morningTime: self.morningTime,
                    eodTime: self.eodTime
                )
            }
        } catch {}
    }
}
