class CreateUserTitles < ActiveRecord::Migration[8.0]
  def change
    create_table :user_titles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :title, null: false, foreign_key: true
      t.datetime :earned_at, null: false
      
      t.timestamps
    end
    
    add_index :user_titles, [:user_id, :title_id], unique: true
  end
end
