class Project < ApplicationRecord
  belongs_to :user
  has_many :milestones, dependent: :destroy
  has_many :daily_goals, dependent: :nullify

  def activity_for(days = 30)
    daily_goals
      .where(date: days.days.ago.to_date..)
      .group(:date)
      .select("date,
               COUNT(*) as goals_set,
               COUNT(CASE WHEN status IN ('complete','partial') THEN 1 END) as goals_completed")
      .map { |r| { date: r.date.to_s, goals_set: r.goals_set, goals_completed: r.goals_completed } }
  end
end
