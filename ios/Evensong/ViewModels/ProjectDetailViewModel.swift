import Foundation

@MainActor
class ProjectDetailViewModel: ObservableObject {
    @Published var project: Project
    @Published var milestones: [Milestone] = []
    @Published var recentGoals: [DailyGoal] = []
    @Published var activity: [ActivityEntry] = []
    @Published var error: String?

    init(project: Project) {
        self.project = project
        self.milestones = project.milestones ?? []
        self.recentGoals = project.recentGoals ?? []
        self.activity = project.activity ?? []
    }

    func load() async {
        do {
            let detail: Project = try await APIClient.shared.request(.projectDetail(id: project.id))
            project = detail
            milestones = detail.milestones ?? []
            recentGoals = detail.recentGoals ?? []
            activity = detail.activity ?? []
        } catch let e as APIError {
            error = e.localizedDescription
        } catch {}
    }

    func addMilestone(_ draft: MilestoneDraft) async {
        struct Body: Encodable {
            let name: String
            let description: String?
            let startDate, targetDate: String?
        }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        do {
            let body = Body(
                name: draft.name,
                description: draft.description.isEmpty ? nil : draft.description,
                startDate: draft.startDate.map { fmt.string(from: $0) },
                targetDate: draft.targetDate.map { fmt.string(from: $0) }
            )
            let ms: Milestone = try await APIClient.shared.request(.createMilestone(projectId: project.id), body: body)
            milestones.append(ms)
        } catch let e as APIError {
            error = e.localizedDescription
        } catch {}
    }

    func updateMilestone(_ id: String, draft: MilestoneDraft) async {
        struct Body: Encodable {
            let name: String
            let description: String?
            let startDate, targetDate: String?
            let status: String
        }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        do {
            let body = Body(
                name: draft.name,
                description: draft.description.isEmpty ? nil : draft.description,
                startDate: draft.startDate.map { fmt.string(from: $0) },
                targetDate: draft.targetDate.map { fmt.string(from: $0) },
                status: draft.status.rawValue
            )
            let ms: Milestone = try await APIClient.shared.request(.updateMilestone(projectId: project.id, id: id), body: body)
            if let i = milestones.firstIndex(where: { $0.id == id }) {
                milestones[i] = ms
            }
        } catch let e as APIError {
            error = e.localizedDescription
        } catch {}
    }

    func deleteMilestone(_ id: String) async {
        struct DeleteResponse: Decodable { let id: String }
        do {
            let _: DeleteResponse = try await APIClient.shared.request(.deleteMilestone(projectId: project.id, id: id))
            milestones.removeAll { $0.id == id }
        } catch let e as APIError {
            error = e.localizedDescription
        } catch {}
    }
}
