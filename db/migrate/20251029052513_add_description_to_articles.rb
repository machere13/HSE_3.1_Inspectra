class AddDescriptionToArticles < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :description, :text unless column_exists?(:articles, :description)
  end
end


