import Foundation

enum APIEndpoint {
    // Auth
    case oauth
    case emailSignUp
    case emailSignIn
    case me
    case patchMe
    case forgotPassword
    case resendConfirmation

    // Projects
    case projects(status: String)
    case createProject
    case projectDetail(id: String)
    case updateProject(id: String)
    case archiveProject(id: String)
    case unarchiveProject(id: String)
    case reorderProjects

    // Milestones
    case milestones(projectId: String)
    case createMilestone(projectId: String)
    case updateMilestone(projectId: String, id: String)
    case deleteMilestone(projectId: String, id: String)

    // Goals
    case goals(date: String)
    case createGoal
    case updateGoal(id: String)
    case checkinGoal(id: String)
    case carryForwardGoal(id: String)

    var method: String {
        switch self {
        case .me, .projects, .projectDetail, .milestones, .goals:
            return "GET"
        case .oauth, .emailSignUp, .emailSignIn, .forgotPassword, .resendConfirmation,
             .createProject, .archiveProject, .unarchiveProject, .reorderProjects,
             .createMilestone, .createGoal, .checkinGoal, .carryForwardGoal:
            return "POST"
        case .patchMe:
            return "PATCH"
        case .updateProject, .updateMilestone, .updateGoal:
            return "PUT"
        case .deleteMilestone:
            return "DELETE"
        }
    }

    var path: String {
        switch self {
        case .oauth:                             return "/v1/oauth"
        case .emailSignUp:                       return "/v1/email_signup"
        case .emailSignIn:                       return "/v1/email_signin"
        case .me, .patchMe:                      return "/v1/me"
        case .forgotPassword:                    return "/v1/forgot_password"
        case .resendConfirmation:                return "/v1/resend_confirmation"
        case .projects(let s):                   return "/v1/projects?status=\(s)"
        case .createProject:                     return "/v1/projects"
        case .reorderProjects:                   return "/v1/projects/reorder"
        case .projectDetail(let id):             return "/v1/projects/\(id)"
        case .updateProject(let id):             return "/v1/projects/\(id)"
        case .archiveProject(let id):            return "/v1/projects/\(id)/archive"
        case .unarchiveProject(let id):          return "/v1/projects/\(id)/unarchive"
        case .milestones(let pid):               return "/v1/projects/\(pid)/milestones"
        case .createMilestone(let pid):          return "/v1/projects/\(pid)/milestones"
        case .updateMilestone(let pid, let id):  return "/v1/projects/\(pid)/milestones/\(id)"
        case .deleteMilestone(let pid, let id):  return "/v1/projects/\(pid)/milestones/\(id)"
        case .goals(let date):                   return "/v1/goals?date=\(date)"
        case .createGoal:                        return "/v1/goals"
        case .updateGoal(let id):                return "/v1/goals/\(id)"
        case .checkinGoal(let id):               return "/v1/goals/\(id)/checkin"
        case .carryForwardGoal(let id):          return "/v1/goals/\(id)/carry_forward"
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .oauth, .emailSignUp, .emailSignIn, .forgotPassword, .resendConfirmation: return false
        default: return true
        }
    }
}
