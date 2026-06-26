class CreateGoals < ActiveRecord::Migration[8.0]
  def change
    create_table :goals do |t|
      t.text :content
      t.string :period, null: false
      t.string :name, limit: 255, null: false
      t.string :status, limit: 255, null: false
      t.boolean :archived, default: false, null: false
      t.uuid :user_id, null: false

      t.timestamps precision: 6
    end

    add_index :goals, :user_id
    add_foreign_key :goals, :users, column: :user_id
  end
end
