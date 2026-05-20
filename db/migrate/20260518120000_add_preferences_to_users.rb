class AddPreferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :theme, :string, default: 'dark', null: false
    add_column :users, :notifications_email, :boolean, default: true, null: false
  end
end
