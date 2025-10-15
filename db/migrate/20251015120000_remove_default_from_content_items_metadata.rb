class RemoveDefaultFromContentItemsMetadata < ActiveRecord::Migration[8.0]
  def change
    change_column_default :content_items, :metadata, from: {}, to: nil
  end
end


