class AddCurrentTitleIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :current_title, null: true, foreign_key: { to_table: :titles }
  end
end
