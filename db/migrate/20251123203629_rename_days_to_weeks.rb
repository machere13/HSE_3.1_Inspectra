class RenameDaysToWeeks < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :articles, :days
    remove_foreign_key :content_items, :days
    
    rename_column :articles, :day_id, :week_id
    rename_column :content_items, :day_id, :week_id
    
    rename_table :days, :weeks
    
    add_foreign_key :articles, :weeks
    add_foreign_key :content_items, :weeks
  end

  def down
    remove_foreign_key :articles, :weeks
    remove_foreign_key :content_items, :weeks
    
    rename_table :weeks, :days
    
    rename_column :articles, :week_id, :day_id
    rename_column :content_items, :week_id, :day_id
    
    add_foreign_key :articles, :days
    add_foreign_key :content_items, :days
  end
end
