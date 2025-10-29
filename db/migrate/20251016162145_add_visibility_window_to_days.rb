class AddVisibilityWindowToDays < ActiveRecord::Migration[8.0]
  def change
    add_column :days, :published_at, :datetime, precision: 6 unless column_exists?(:days, :published_at)
    add_column :days, :expires_at, :datetime, precision: 6 unless column_exists?(:days, :expires_at)

    reversible do |dir|
      dir.up do
        if column_exists?(:days, :published_at) && column_exists?(:days, :expires_at)
          execute <<~SQL
            UPDATE days
            SET published_at = COALESCE(published_at, NOW()),
                expires_at   = COALESCE(expires_at, NOW() + interval '24 hours')
            WHERE published_at IS NULL OR expires_at IS NULL;
          SQL

          begin
            change_column_null :days, :published_at, false
            change_column_null :days, :expires_at, false
          rescue StandardError
          end
        end
      end
    end

    add_index :days, :published_at unless index_exists?(:days, :published_at)
    add_index :days, :expires_at unless index_exists?(:days, :expires_at)
    add_index :days, [:published_at, :expires_at] unless index_exists?(:days, [:published_at, :expires_at])
  end
end


