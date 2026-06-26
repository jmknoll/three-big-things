class DailyGoal < ApplicationRecord
  belongs_to :user
  belongs_to :project
  belongs_to :milestone, optional: true
  belongs_to :original_goal, class_name: 'DailyGoal', foreign_key: :carry_forward_of, optional: true
  has_one    :carry_forward_copy, class_name: 'DailyGoal', foreign_key: :carry_forward_of

  def goal_json
    as_json.merge(
      project:   project.as_json(only: [:id, :name, :color]),
      milestone: milestone&.as_json(only: [:id, :name])
    )
  end
end
