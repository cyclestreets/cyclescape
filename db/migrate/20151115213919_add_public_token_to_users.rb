class AddPublicTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :public_token, :string
    add_index :users, :public_token, unique: true
    User.unscoped.find_each do |user|
      user.update_column(:public_token, SecureRandom.hex(10))
    end
    change_column_null :users, :public_token, false
  end
end
