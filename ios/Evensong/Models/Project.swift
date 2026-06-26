import Foundation

struct Project: Codable, Identifiable {
    let id: String
    let userId: String?
    let name: String
    let color: ProjectColor
    let description: String?
    let targetQuarter: String?
    let status: ProjectStatus
    let sortOrder: Int
    let archivedAt: String?
    let createdAt: String?
    let updatedAt: String?
    let milestoneCount: Int?
    let activity: [ActivityEntry]?
    // Included in detail response
    let milestones: [Milestone]?
    let recentGoals: [DailyGoal]?
}

struct ActivityEntry: Codable {
    let date: String
    let goalsSet: Int
    let goalsCompleted: Int
}

enum ProjectStatus: String, Codable {
    case active, archived
}

struct ProjectDraft {
    var name: String
    var color: ProjectColor
    var description: String
    var targetQuarter: String
}

// Lightweight ref embedded in goal responses
struct ProjectRef: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let color: ProjectColor
}
