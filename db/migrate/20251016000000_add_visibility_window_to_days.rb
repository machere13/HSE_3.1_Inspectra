class AddVisibilityWindowToDays < ActiveRecord::Migration[8.0]
  def change
    add_column :days, :published_at, :datetime, precision: 6
    add_column :days, :expires_at, :datetime, precision: 6

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE days
          SET published_at = NOW(),
              expires_at   = NOW() + interval '24 hours'
          WHERE published_at IS NULL OR expires_at IS NULL;
        SQL

        change_column_null :days, :published_at, false
        change_column_null :days, :expires_at, false
      end
    end

    add_index :days, :published_at
    add_index :days, :expires_at
    add_index :days, [:published_at, :expires_at]
  end
end


