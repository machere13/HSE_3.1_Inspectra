class CreateContentItems < ActiveRecord::Migration[8.0]
  def change
    create_table :content_items do |t|
      t.references :day, null: false, foreign_key: true
      t.references :article, null: true, foreign_key: true
      t.string :kind
      t.string :title
      t.text :body
      t.string :url
      t.integer :position
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    add_index :content_items, :kind
    add_index :content_items, [:day_id, :position]
  end
end
