class SyncAdminUsersToRoles < ActiveRecord::Migration[8.0]
  def up
    return unless column_exists?(:users, :admin) && column_exists?(:users, :role)

    User.where(admin: true, role: :user).update_all(role: :admin)
  end

  def down
  end
end
