class CreateRevokedTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :revoked_tokens do |t|
      t.string :jti
      t.datetime :expires_at

      t.timestamps
    end
    add_index :revoked_tokens, :jti, unique: true
  end
end
