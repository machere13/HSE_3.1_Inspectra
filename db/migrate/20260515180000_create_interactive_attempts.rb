class CreateInteractiveAttempts < ActiveRecord::Migration[8.0]
  def change
    create_table :interactive_attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :interactive, null: false, foreign_key: true
      t.integer :count, default: 0, null: false
      t.datetime :last_attempt_at
      t.datetime :locked_until

      t.timestamps
    end

    add_index :interactive_attempts, [:user_id, :interactive_id], unique: true
    add_index :interactive_attempts, :locked_until
  end
end
