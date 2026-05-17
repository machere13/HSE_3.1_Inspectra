class CreateInteractiveVariants < ActiveRecord::Migration[8.0]
  def change
    create_table :interactive_variants do |t|
      t.references :interactive, null: false, foreign_key: true
      t.integer :seed, null: false
      t.jsonb :payload, default: {}, null: false

      t.timestamps
    end

    add_index :interactive_variants, [:interactive_id, :seed], unique: true
  end
end
