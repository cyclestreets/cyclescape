class AddMessageThreadsPublicTokenColumn < ActiveRecord::Migration
  def up
    add_column :message_threads, :public_token, :string
  end

  def down
    remove_column :message_threads, :public_token
  end
end
