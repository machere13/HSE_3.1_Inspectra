class AddGameRoleAndXpToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :game_role, :integer
    add_column :users, :game_role_selected_at, :datetime
    add_column :users, :experience_points, :integer, default: 0, null: false

    add_index :users, :game_role
  end
end
