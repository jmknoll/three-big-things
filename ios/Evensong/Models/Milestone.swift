import Foundation

struct Milestone: Codable, Identifiable {
    let id: String
    let projectId: String?
    let name: String
    let description: String?
    let startDate: String?
    let targetDate: String?
    let status: MilestoneStatus
    let sortOrder: Int?
    let completedAt: String?
    let createdAt: String?
    let updatedAt: String?
}

enum MilestoneStatus: String, Codable {
    case active, complete, skipped
}

struct MilestoneRef: Codable, Identifiable, Equatable {
    let id: String
    let name: String
}

struct MilestoneDraft {
    var name: String
    var description: String
    var startDate: Date?
    var targetDate: Date?
    var status: MilestoneStatus
}
