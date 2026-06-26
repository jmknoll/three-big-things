import Foundation

struct DailyGoal: Codable, Identifiable {
    let id: String
    let userId: String?
    let projectId: String?
    let milestoneId: String?
    let carryForwardOf: String?
    let text: String
    let date: String
    let slot: Int
    let status: GoalStatus
    let carriedForward: Bool
    let noteText: String?
    let completedAt: String?
    let createdAt: String?
    let updatedAt: String?
    let project: ProjectRef?
    let milestone: MilestoneRef?
}

enum GoalStatus: String, Codable {
    case pending
    case complete
    case partial
    case carried_forward = "carried_forward"
    case expired
}

// Used when creating goals in the morning entry
struct GoalDraft {
    var text: String = ""
    var assignment: Assignment?
}

// Used when submitting EOD check-in
struct GoalCheckIn {
    var goalId: String
    var status: GoalStatus
    var noteText: String = ""
    var carryForward: Bool = false
}

// Assignment binding value
struct Assignment: Equatable {
    var project: ProjectRef
    var milestone: MilestoneRef?
}
