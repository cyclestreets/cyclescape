class AddDeletedAtToMessageThreads < ActiveRecord::Migration
  def up
    add_column :message_threads, :deleted_at, :datetime
  end

  def down
    remove_column :message_threads, :deleted_at
  end
end
