import Foundation

enum TodayState: Equatable {
    case loading
    case morningEntry(prefilledGoals: [DailyGoal])
    case readView(goals: [DailyGoal])
    case eodCheckIn(goals: [DailyGoal])
    case complete(goals: [DailyGoal])
    case staleResolution(staleGoals: [DailyGoal], then: TodayStateContinuation)

    static func == (lhs: TodayState, rhs: TodayState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        default: return false
        }
    }
}

// Continuation is a separate type to avoid recursive enums
enum TodayStateContinuation {
    case morningEntry(prefilledGoals: [DailyGoal])
}

private struct CreateGoalBody: Encodable {
    let text: String
    let date: String
    let slot: Int
    let projectId: String
    let milestoneId: String?
}

private struct CheckInBody: Encodable {
    let status: String
    let noteText: String?
}

@MainActor
class TodayViewModel: ObservableObject {
    @Published var state: TodayState = .loading
    @Published var toast: String?
    @Published var user: User?

    func refresh(user: User) async {
        self.user = user
        state = .loading

        let todayStr = Date.today.isoDateString
        let yesterdayStr = Calendar.current.date(byAdding: .day, value: -1, to: Date.today)!.isoDateString

        do {
            let todayGoals: [DailyGoal] = try await APIClient.shared.request(.goals(date: todayStr))

            if todayGoals.count < 3 {
                let yesterdayGoals: [DailyGoal] = (try? await APIClient.shared.request(.goals(date: yesterdayStr))) ?? []
                let stale = yesterdayGoals.filter { $0.status == .pending }
                let carryForwards = yesterdayGoals.filter { $0.carriedForward }
                let continuation = TodayStateContinuation.morningEntry(prefilledGoals: carryForwards)

                if stale.isEmpty {
                    state = .morningEntry(prefilledGoals: carryForwards)
                } else {
                    state = .staleResolution(staleGoals: stale, then: continuation)
                }
            } else {
                let allSettled = todayGoals.allSatisfy { $0.status != .pending }
                if allSettled {
                    state = .complete(goals: todayGoals)
                    return
                }
                if let eodDate = user.eodReminderTime.timeToday, Date() >= eodDate {
                    state = .eodCheckIn(goals: todayGoals)
                } else {
                    state = .readView(goals: todayGoals)
                }
            }
        } catch {
            // Stay in loading on network error — toast shown
            toast = "Could not load today's goals."
        }
    }

    func submitGoals(_ drafts: [GoalDraft]) async {
        let dateStr = Date.today.isoDateString
        var created: [DailyGoal] = []

        for (index, draft) in drafts.enumerated() {
            guard let assignment = draft.assignment else { continue }
            let body = CreateGoalBody(
                text: draft.text,
                date: dateStr,
                slot: index + 1,
                projectId: assignment.project.id,
                milestoneId: assignment.milestone?.id
            )
            do {
                let goal: DailyGoal = try await APIClient.shared.request(.createGoal, body: body)
                created.append(goal)
            } catch let e as APIError {
                toast = e.localizedDescription
                return
            } catch {
                toast = "Failed to save goals."
                return
            }
        }

        HapticManager.light()
        state = .readView(goals: created)
    }

    func submitCheckIn(_ checkIns: [GoalCheckIn]) async {
        var updated: [DailyGoal] = []

        for ci in checkIns {
            let body = CheckInBody(status: ci.status.rawValue, noteText: ci.noteText.isEmpty ? nil : ci.noteText)
            do {
                let goal: DailyGoal = try await APIClient.shared.request(.checkinGoal(id: ci.goalId), body: body)
                updated.append(goal)
                if ci.carryForward {
                    let _: DailyGoal = (try? await APIClient.shared.request(.carryForwardGoal(id: ci.goalId))) ?? goal
                }
            } catch let e as APIError {
                toast = e.localizedDescription
                return
            } catch {
                toast = "Check-in failed."
                return
            }
        }

        HapticManager.medium()
        state = .complete(goals: updated)
    }

    func resolveStale(_ checkIns: [GoalCheckIn], continuation: TodayStateContinuation) async {
        for ci in checkIns {
            let body = CheckInBody(status: ci.status.rawValue, noteText: ci.noteText.isEmpty ? nil : ci.noteText)
            _ = try? await APIClient.shared.request(.checkinGoal(id: ci.goalId), body: body) as DailyGoal
            if ci.carryForward {
                _ = try? await APIClient.shared.request(.carryForwardGoal(id: ci.goalId)) as DailyGoal
            }
        }
        switch continuation {
        case .morningEntry(let prefills):
            state = .morningEntry(prefilledGoals: prefills)
        }
    }
}
