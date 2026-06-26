class CreateMilestones < ActiveRecord::Migration[8.0]
  def change
    create_table :milestones, id: false do |t|
      t.column :id, :uuid, primary_key: true, default: -> { "gen_random_uuid()" }, null: false
      t.references :project, type: :uuid, foreign_key: true, null: false
      t.string  :name,        null: false
      t.string  :description
      t.date    :start_date
      t.date    :target_date
      t.string  :status,      null: false, default: "active"
      t.integer :sort_order,  null: false, default: 0
      t.datetime :completed_at

      t.timestamps
    end

    add_index :milestones, [:project_id, :sort_order]
  end
end
