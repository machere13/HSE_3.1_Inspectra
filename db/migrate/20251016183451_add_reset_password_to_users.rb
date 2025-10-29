class AddResetPasswordToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :reset_password_token, :string unless column_exists?(:users, :reset_password_token)
    add_column :users, :reset_password_sent_at, :datetime unless column_exists?(:users, :reset_password_sent_at)
    add_column :users, :reset_password_requested_at, :datetime unless column_exists?(:users, :reset_password_requested_at)
    add_index  :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)
  end
end


