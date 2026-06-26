class Milestone < ApplicationRecord
  belongs_to :project
  has_many :daily_goals, foreign_key: :milestone_id, dependent: :nullify
end
