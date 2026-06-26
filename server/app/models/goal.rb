class Goal < ApplicationRecord
  self.table_name = 'goals'

  belongs_to :user, foreign_key: 'user_id'
end
