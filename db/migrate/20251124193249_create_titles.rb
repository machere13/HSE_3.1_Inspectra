class CreateTitles < ActiveRecord::Migration[8.0]
  def change
    create_table :titles do |t|
      t.string :name, null: false
      t.text :description
      
      t.timestamps
    end
    
    add_index :titles, :name, unique: true
  end
end
