class AddSessionToInteractiveAttempts < ActiveRecord::Migration[8.0]
  def change
    add_column :interactive_attempts, :session_token, :string
    add_column :interactive_attempts, :session_expires_at, :datetime

    add_index :interactive_attempts, :session_token, unique: true
  end
end
