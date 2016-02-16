class MakeEmailsAndDisplayNamesUnique < ActiveRecord::Migration
  def change
    remove_index :users, :email
    add_index :users, :email, unique: true
    add_index :users, :display_name, unique: true
  end
end
