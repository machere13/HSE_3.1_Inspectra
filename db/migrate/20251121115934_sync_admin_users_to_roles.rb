class SyncAdminUsersToRoles < ActiveRecord::Migration[8.0]
  def up
    return unless column_exists?(:users, :admin) && column_exists?(:users, :role)

    execute <<-SQL
      UPDATE users
      SET role = 2
      WHERE admin = true AND role = 0
    SQL
  end

  def down
  end
end
