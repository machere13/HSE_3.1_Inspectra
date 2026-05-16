class AddStreakFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :current_streak_days, :integer, default: 0, null: false
    add_column :users, :longest_streak_days, :integer, default: 0, null: false
    add_column :users, :last_content_view_on, :date
    add_column :users, :platform_lifetime_marked_at, :datetime
    add_column :users, :last_day_witnessed_at, :datetime

    add_index :users, :last_content_view_on
  end
end
