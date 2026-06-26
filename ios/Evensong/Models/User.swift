import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String?
    let timezoneOffset: Int?
    let metaStreakCurrent: Int
    let metaStreakLongest: Int
    let streakLastCalcDate: String?
    let morningReminderTime: String
    let eodReminderTime: String
    let notificationsEnabled: Bool
    let emailConfirmed: Bool
    let onboardingDone: Bool
    let createdAt: String?
    let updatedAt: String?
}
