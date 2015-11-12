class AddClosedToMessageThreads < ActiveRecord::Migration
  def change
    add_column :message_threads, :closed, :boolean, null: false, default: false
  end
end
