class AddPublicTokenToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :public_token, :string
    add_index :messages, :public_token, unique: true
  end
end
