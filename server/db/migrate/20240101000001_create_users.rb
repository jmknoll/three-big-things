class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'pgcrypto'

    create_table :users, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, limit: 255
      t.string :email, limit: 255, null: false
      t.string :password, limit: 255
      t.uuid :refresh_token
      t.integer :timezone_offset
      t.integer :streak
      t.datetime :last_login, precision: 6

      t.timestamps precision: 6
    end

    add_index :users, :email, unique: true
    add_index :users, [:id, :email]
  end
end
