class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects, id: false do |t|
      t.column :id, :uuid, primary_key: true, default: -> { "gen_random_uuid()" }, null: false
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.string  :name,           null: false
      t.string  :color,          null: false
      t.string  :description
      t.string  :target_quarter
      t.string  :status,         null: false, default: "active"
      t.integer :sort_order,     null: false, default: 0
      t.datetime :archived_at

      t.timestamps
    end

    add_index :projects, [:user_id, :status]
    add_index :projects, [:user_id, :sort_order]
  end
end
