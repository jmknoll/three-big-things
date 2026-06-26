class GoalsController < ApplicationController
  before_action :authenticate!

  def index
    archived = params[:archived] == 'true'
    goals = Goal.where(user_id: @current_user_id, archived: archived)
                .order(created_at: :asc)
    render json: goals
  end

  def create
    goal = Goal.create!(
      name: params[:name],
      content: params[:content],
      period: params[:period],
      status: params[:status],
      user_id: @current_user_id
    )
    render json: goal
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def update
    goal = Goal.find(params[:id])
    attrs = {
      name: params[:name],
      content: params[:content],
      period: params[:period],
      status: params[:status]
    }
    attrs[:archived] = params[:archived] unless params[:archived].nil?
    goal.update!(attrs)
    render json: goal
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def destroy
    goal = Goal.find(params[:id])
    goal.destroy!
    render json: { id: goal.id }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
