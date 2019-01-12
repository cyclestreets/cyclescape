class CreateUserBlocks < ActiveRecord::Migration
  def change
    create_table :user_blocks do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.integer :blocked_id, null: false

      t.timestamps null: false
    end
    add_index :user_blocks, [:blocked_id, :user_id], unique: true
    add_foreign_key(:user_blocks, :users, column: :blocked_id)
  end
end
