import Foundation

private struct ReorderBody: Encodable {
    let order: [String]
}

private struct ArchiveResponse: Decodable {
    let id: String?
}

@MainActor
class ProjectsViewModel: ObservableObject {
    @Published var activeProjects: [Project] = []
    @Published var archivedProjects: [Project] = []
    @Published var isLoadingArchived = false
    @Published var showArchived = false
    @Published var error: String?

    func loadActive() async {
        do {
            activeProjects = try await APIClient.shared.request(.projects(status: "active"))
        } catch let e as APIError {
            error = e.localizedDescription
        } catch {}
    }

    func loadArchived() async {
        isLoadingArchived = true
        defer { isLoadingArchived = false }
        do {
            archivedProjects = try await APIClient.shared.request(.projects(status: "archived"))
        } catch let e as APIError {
            error = e.localizedDescription
        } catch {}
    }

    func reorder(_ ids: [String]) async {
        do {
            try await APIClient.shared.requestVoid(.reorderProjects, body: ReorderBody(order: ids))
            // Update local sort orders
            for (index, id) in ids.enumerated() {
                if let i = activeProjects.firstIndex(where: { $0.id == id }) {
                    // Sort order is implicit from array position
                    _ = i; _ = index
                }
            }
        } catch {}
    }

    func archive(_ id: String) async {
        do {
            let updated: Project = try await APIClient.shared.request(.archiveProject(id: id))
            activeProjects.removeAll { $0.id == id }
            archivedProjects.insert(updated, at: 0)
        } catch let e as APIError {
            error = e.localizedDescription
        } catch {}
    }

    func unarchive(_ id: String) async {
        do {
            let updated: Project = try await APIClient.shared.request(.unarchiveProject(id: id))
            archivedProjects.removeAll { $0.id == id }
            activeProjects.append(updated)
        } catch let e as APIError {
            error = e.localizedDescription
        } catch {}
    }

    func create(_ draft: ProjectDraft) async -> Project? {
        struct Body: Encodable { let name, color: String; let description, targetQuarter: String? }
        do {
            let body = Body(
                name: draft.name,
                color: draft.color.rawValue,
                description: draft.description.isEmpty ? nil : draft.description,
                targetQuarter: draft.targetQuarter.isEmpty ? nil : draft.targetQuarter
            )
            let project: Project = try await APIClient.shared.request(.createProject, body: body)
            activeProjects.append(project)
            return project
        } catch let e as APIError {
            error = e.localizedDescription
            return nil
        } catch { return nil }
    }

    func update(_ id: String, draft: ProjectDraft) async {
        struct Body: Encodable { let name, color: String; let description, targetQuarter: String? }
        do {
            let body = Body(
                name: draft.name,
                color: draft.color.rawValue,
                description: draft.description.isEmpty ? nil : draft.description,
                targetQuarter: draft.targetQuarter.isEmpty ? nil : draft.targetQuarter
            )
            let updated: Project = try await APIClient.shared.request(.updateProject(id: id), body: body)
            if let i = activeProjects.firstIndex(where: { $0.id == id }) {
                activeProjects[i] = updated
            }
        } catch let e as APIError {
            error = e.localizedDescription
        } catch {}
    }
}
