class AddUniqToGroupMemberships < ActiveRecord::Migration
  def change
    user_groups = GroupMembership.all.group(:user_id, :group_id).count.select{ |k,v| k if v > 1 }.keys
    user_groups.each do |ug|
      first = true
      GroupMembership.where(user_id: ug[0]).where(group_id: ug[1]).each do |gm|
        gm.destroy unless first
        first = false
      end
    end
    user_req = GroupMembershipRequest.all.group(:user_id, :group_id).count.select{ |k,v| k if v > 1 }.keys
    user_req.each do |ur|
      first = true
      GroupMembershipRequest.where(user_id: ur[0]).where(group_id: ur[1]).each do |gmr|
        gmr.destroy unless first
        first = false
      end
    end

    add_index :group_memberships, [:user_id, :group_id], unique: true
    add_index :group_membership_requests, [:user_id, :group_id], unique: true
  end
end
