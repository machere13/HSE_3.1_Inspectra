class AddTitleIdToAchievements < ActiveRecord::Migration[8.0]
  def change
    add_reference :achievements, :title, foreign_key: true, null: true
  end
end
