class CreateInteractives < ActiveRecord::Migration[8.0]
  def change
    create_table :interactives do |t|
      t.string :key, null: false
      t.string :category, null: false
      t.string :kind, null: false
      t.string :title, null: false
      t.text :description
      t.integer :xp_reward, default: 50, null: false
      t.integer :difficulty, default: 1, null: false

      t.timestamps
    end

    add_index :interactives, :key, unique: true
    add_index :interactives, :category
    add_index :interactives, :kind
  end
end
