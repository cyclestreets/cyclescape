class AddMessageToGroupMembershipRequests < ActiveRecord::Migration
  def change
    add_column :group_membership_requests, :message, :text
  end
end
