class AddChecksToMessageThreads < ActiveRecord::Migration
  def change
    add_column :message_threads, :status, :string
    add_column :message_threads, :check_reason, :string
  end
end
