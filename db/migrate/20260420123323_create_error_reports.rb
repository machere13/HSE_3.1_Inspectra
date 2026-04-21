class CreateErrorReports < ActiveRecord::Migration[8.0]
  def change
    create_table :error_reports do |t|
      t.string :page_url
      t.string :status_code
      t.string :reporter_email
      t.text :message, null: false

      t.timestamps
    end

    add_index :error_reports, :created_at
    add_index :error_reports, :status_code
  end
end
