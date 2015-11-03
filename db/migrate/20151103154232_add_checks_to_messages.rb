class AddChecksToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :status, :string
    add_column :messages, :check_reason, :string
    update "UPDATE messages SET status = 'approved' WHERE status IS NULL"
    update "UPDATE message_threads SET status = 'approved' WHERE status IS NULL"
    remove_column :message_threads, :check_reason, :string
  end
end
