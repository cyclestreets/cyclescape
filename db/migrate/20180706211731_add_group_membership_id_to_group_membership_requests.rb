class AddGroupMembershipIdToGroupMembershipRequests < ActiveRecord::Migration
  def change
    add_reference :group_membership_requests, :group_membership, index: true, foreign_key: true
    delete <<~SQL
      DELETE FROM group_membership_requests gmr
      USING group_memberships gm
      WHERE gmr.user_id = gm.user_id
      AND gmr.group_id = gm.group_id
      AND status = 'pending'
    SQL
  end
end
