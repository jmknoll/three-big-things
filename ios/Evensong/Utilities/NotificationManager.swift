import UserNotifications

enum TodayDeepLink {
    case morning
    case evening
}

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private let morningID = "evensong.morning"
    private let eodID     = "evensong.eod"

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleAll(morningTime: String, eodTime: String) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [morningID, eodID])

        if let (mHour, mMin) = parseTime(morningTime) {
            scheduleDaily(id: morningID, hour: mHour, minute: mMin,
                          title: "Time to set your intentions",
                          body: "What three things matter most today?")
        }
        if let (eHour, eMin) = parseTime(eodTime) {
            scheduleDaily(id: eodID, hour: eHour, minute: eMin,
                          title: "How did today go?",
                          body: "Take a moment to check in on your goals.")
        }
    }

    func suppressMorningIfNeeded(todayGoalsCount: Int) {
        if todayGoalsCount >= 3 {
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: [morningID])
        }
    }

    func suppressEODIfNeeded(allCheckedIn: Bool) {
        if allCheckedIn {
            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: [eodID])
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    // MARK: - Private

    private func scheduleDaily(id: String, hour: Int, minute: Int, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func parseTime(_ time: String) -> (Int, Int)? {
        let parts = time.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        return (parts[0], parts[1])
    }
}
