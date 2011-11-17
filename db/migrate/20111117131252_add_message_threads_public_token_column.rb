class AddMessageThreadsPublicTokenColumn < ActiveRecord::Migration
  def up
    add_column :message_threads, :public_token, :string
    add_index :message_threads, :public_token, unique: true
  end

  def down
    remove_column :message_threads, :public_token
  end
end
