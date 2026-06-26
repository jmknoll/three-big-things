class AddEmailAuthFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :email_confirmed,        :boolean, default: false, null: false unless column_exists?(:users, :email_confirmed)
    add_column :users, :confirmation_token,     :string                                unless column_exists?(:users, :confirmation_token)
    add_column :users, :confirmation_sent_at,   :datetime                              unless column_exists?(:users, :confirmation_sent_at)
    add_column :users, :reset_password_token,   :string                                unless column_exists?(:users, :reset_password_token)
    add_column :users, :reset_password_sent_at, :datetime                              unless column_exists?(:users, :reset_password_sent_at)

    add_index :users, :confirmation_token,   unique: true, where: "confirmation_token IS NOT NULL"   unless index_exists?(:users, :confirmation_token)
    add_index :users, :reset_password_token, unique: true, where: "reset_password_token IS NOT NULL" unless index_exists?(:users, :reset_password_token)
  end
end
