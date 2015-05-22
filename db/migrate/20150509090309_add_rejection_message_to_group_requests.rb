class AddRejectionMessageToGroupRequests < ActiveRecord::Migration
  def change
    add_column :group_requests, :rejection_message, :text
  end
end
