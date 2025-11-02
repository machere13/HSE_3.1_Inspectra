class CreateJwtSecretRotations < ActiveRecord::Migration[8.0]
  def change
    create_table :jwt_secret_rotations do |t|
      t.datetime :rotated_at, null: false
      t.string :rotated_by, null: false
      t.string :rotation_type, null: false
      t.text :metadata

      t.timestamps
    end

    add_index :jwt_secret_rotations, :rotated_at
    add_index :jwt_secret_rotations, :rotation_type
  end
end

