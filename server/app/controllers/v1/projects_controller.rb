module V1
  class ProjectsController < V1::BaseController
    before_action :authenticate!

    def index
      status_filter = params[:status] || "active"
      projects = Project.where(user_id: @current_user_id, status: status_filter)
                        .order(:sort_order)

      render json: projects.map { |p|
        p.as_json.merge(
          milestone_count: p.milestones.count,
          activity: p.activity_for(30)
        )
      }
    end

    def create
      max_order = Project.where(user_id: @current_user_id).maximum(:sort_order) || -1
      project = Project.new(project_params.merge(user_id: @current_user_id, sort_order: max_order + 1))

      if project.save
        render json: project.as_json.merge(milestone_count: 0, activity: []), status: :created
      else
        render json: { errors: project.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def show
      project = Project.where(user_id: @current_user_id).find(params[:id])
      recent_goals = project.daily_goals
                            .where(date: 7.days.ago.to_date..)
                            .order(date: :desc, slot: :asc)

      render json: project.as_json.merge(
        milestones: project.milestones.order(:sort_order),
        recent_goals: recent_goals.map(&:goal_json),
        activity: project.activity_for(30)
      )
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Not found" }, status: :not_found
    end

    def update
      project = Project.where(user_id: @current_user_id).find(params[:id])
      project.update!(project_params)
      render json: project
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Not found" }, status: :not_found
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def archive
      project = Project.where(user_id: @current_user_id).find(params[:id])

      if project.status == "archived"
        return render json: { error: "Already archived" }, status: :unprocessable_entity
      end

      project.update!(status: "archived", archived_at: Time.now)
      render json: project
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Not found" }, status: :not_found
    end

    def unarchive
      project = Project.where(user_id: @current_user_id).find(params[:id])
      project.update!(status: "active", archived_at: nil)
      render json: project
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Not found" }, status: :not_found
    end

    def reorder
      ids = params[:order]
      return render json: { error: "order is required" }, status: :unprocessable_entity unless ids.is_a?(Array)

      user_project_ids = Project.where(user_id: @current_user_id).pluck(:id).map(&:to_s)
      unless ids.all? { |id| user_project_ids.include?(id.to_s) }
        return render json: { error: "Invalid project IDs" }, status: :unprocessable_entity
      end

      ids.each_with_index do |id, index|
        Project.where(id: id, user_id: @current_user_id).update_all(sort_order: index)
      end

      render json: { ok: true }
    end

    private

    def project_params
      params.permit(:name, :color, :description, :target_quarter)
    end
  end
end
