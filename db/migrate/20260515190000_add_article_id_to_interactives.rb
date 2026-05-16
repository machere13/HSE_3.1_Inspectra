class AddArticleIdToInteractives < ActiveRecord::Migration[8.0]
  def change
    add_reference :interactives, :article, foreign_key: true, null: true
  end
end
