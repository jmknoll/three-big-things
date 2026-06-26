class CreateDailyGoals < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_goals, id: false do |t|
      t.column :id, :uuid, primary_key: true, default: -> { "gen_random_uuid()" }, null: false
      t.references :user,      type: :uuid, foreign_key: true,                   null: false
      t.references :project,   type: :uuid, foreign_key: true,                   null: false
      t.references :milestone, type: :uuid, foreign_key: true,                   null: true
      t.column :carry_forward_of, :uuid
      t.string  :text,             null: false
      t.date    :date,             null: false
      t.integer :slot,             null: false
      t.string  :status,           null: false, default: "pending"
      t.boolean :carried_forward,  null: false, default: false
      t.string  :note_text
      t.datetime :completed_at

      t.timestamps
    end

    add_index :daily_goals, [:user_id, :date]
    add_index :daily_goals, [:project_id, :date]
    add_index :daily_goals, :carry_forward_of
    add_index :daily_goals, [:user_id, :date, :slot], unique: true

    add_foreign_key :daily_goals, :daily_goals, column: :carry_forward_of
  end
end
