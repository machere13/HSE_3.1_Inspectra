class CreateLevels < ActiveRecord::Migration[8.0]
  def change
    create_table :levels do |t|
      t.integer :number, null: false
      t.integer :required_xp, null: false, default: 0
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    add_index :levels, :number, unique: true
    add_index :levels, :required_xp
  end
end
