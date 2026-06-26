class AddIntentionFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :meta_streak_current,   :integer, default: 0,       null: false
    add_column :users, :meta_streak_longest,   :integer, default: 0,       null: false
    add_column :users, :streak_last_calc_date, :date
    add_column :users, :morning_reminder_time, :string,  default: "08:00", null: false
    add_column :users, :eod_reminder_time,     :string,  default: "20:00", null: false
    add_column :users, :notifications_enabled, :boolean, default: true,    null: false
    add_column :users, :onboarding_done,       :boolean, default: false,   null: false
  end
end
