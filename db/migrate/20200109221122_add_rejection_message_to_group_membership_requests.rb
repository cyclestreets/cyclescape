class AddRejectionMessageToGroupMembershipRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :group_membership_requests, :rejection_message, :text
  end
end
