class RelaxInteractiveCompletions < ActiveRecord::Migration[8.0]
  def change
    change_column_null :interactive_completions, :article_id, true
    add_reference :interactive_completions, :interactive, foreign_key: true, null: true
    add_reference :interactive_completions, :interactive_variant, foreign_key: true, null: true
  end
end
