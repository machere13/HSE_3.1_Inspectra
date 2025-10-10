class CreateDays < ActiveRecord::Migration[8.0]
  def change
    create_table :days do |t|
      t.integer :number
      t.string :title
      t.text :description

      t.timestamps
    end
    add_index :days, :number, unique: true
  end
end
