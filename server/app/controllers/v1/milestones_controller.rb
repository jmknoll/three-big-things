module V1
  class MilestonesController < V1::BaseController
    before_action :authenticate!
    before_action :load_project

    def index
      render json: @project.milestones.order(:sort_order)
    end

    def create
      max_order = @project.milestones.maximum(:sort_order) || -1
      milestone = @project.milestones.new(milestone_params.merge(sort_order: max_order + 1))

      if milestone.save
        render json: milestone, status: :created
      else
        render json: { errors: milestone.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      milestone = @project.milestones.find(params[:id])
      attrs = milestone_params.to_h

      if attrs['status'] == 'complete'
        attrs['completed_at'] = Time.now
      elsif attrs['status'] == 'active'
        attrs['completed_at'] = nil
      end

      milestone.update!(attrs)
      render json: milestone
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def destroy
      milestone = @project.milestones.find(params[:id])
      milestone.destroy!
      render json: { id: milestone.id }
    end

    private

    def load_project
      @project = Project.where(user_id: @current_user_id).find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Project not found" }, status: :not_found
    end

    def milestone_params
      params.permit(:name, :description, :start_date, :target_date, :status)
    end
  end
end
