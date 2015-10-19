class AddPublicTokenToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :public_token, :string
    Message.find_each do |message|
      message.update_column(:public_token, SecureRandom.hex(10))
    end
    change_column :messages, :public_token, :string, null: false
    add_index :messages, :public_token, unique: true
  end
end
