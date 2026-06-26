module V1
  class GoalsController < V1::BaseController
    before_action :authenticate!

    def index
      return render json: { error: "date is required" }, status: :bad_request unless params[:date]

      goals = DailyGoal.where(user_id: @current_user_id, date: params[:date])
                       .order(:slot)
      render json: goals.map(&:goal_json)
    end

    def create
      goal = DailyGoal.new(create_params.merge(user_id: @current_user_id))

      if params[:milestone_id].present?
        milestone = Milestone.joins(:project)
                             .where(id: params[:milestone_id], projects: { id: params[:project_id] })
                             .first
        return render json: { error: "Milestone does not belong to project" }, status: :unprocessable_entity unless milestone
      end

      if goal.save
        render json: goal.goal_json, status: :created
      else
        render json: { errors: goal.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotUnique
      render json: { error: "Slot already taken for that date" }, status: :unprocessable_entity
    end

    def update
      goal = DailyGoal.where(user_id: @current_user_id).find(params[:id])
      attrs = update_params.to_h

      if attrs['milestone_id'].present?
        project_id = attrs['project_id'] || goal.project_id
        milestone = Milestone.joins(:project)
                             .where(id: attrs['milestone_id'], projects: { id: project_id })
                             .first
        return render json: { error: "Milestone does not belong to project" }, status: :unprocessable_entity unless milestone
      end

      goal.update!(attrs)
      render json: goal.goal_json
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Not found" }, status: :not_found
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def checkin
      goal = DailyGoal.where(user_id: @current_user_id).find(params[:id])

      if goal.date < 7.days.ago.to_date
        return render json: { error: "Cannot check in a goal older than 7 days" }, status: :unprocessable_entity
      end

      allowed = %w[complete partial carried_forward expired]
      status = params[:status]
      return render json: { error: "Invalid status" }, status: :unprocessable_entity unless allowed.include?(status)

      attrs = { status: status }
      attrs[:completed_at] = Time.now if %w[complete partial].include?(status)

      goal.update!(attrs)
      render json: goal.goal_json
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Not found" }, status: :not_found
    end

    def carry_forward
      goal = DailyGoal.where(user_id: @current_user_id).find(params[:id])

      if goal.carried_forward
        return render json: { error: "Goal already carried forward" }, status: :unprocessable_entity
      end

      next_date = goal.date + 1
      next_day_count = DailyGoal.where(user_id: @current_user_id, date: next_date).count
      if next_day_count >= 3
        return render json: { error: "All slots for next day are filled" }, status: :unprocessable_entity
      end

      next_slot = DailyGoal.where(user_id: @current_user_id, date: next_date).maximum(:slot).to_i + 1

      new_goal = DailyGoal.create!(
        user_id:          @current_user_id,
        project_id:       goal.project_id,
        milestone_id:     goal.milestone_id,
        carry_forward_of: goal.id,
        text:             goal.text,
        date:             next_date,
        slot:             next_slot,
        status:           "pending"
      )

      goal.update!(carried_forward: true)

      render json: new_goal.goal_json, status: :created
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Not found" }, status: :not_found
    end

    private

    def create_params
      params.permit(:text, :date, :slot, :project_id, :milestone_id)
    end

    def update_params
      params.permit(:text, :project_id, :milestone_id)
    end
  end
end
