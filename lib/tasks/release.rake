namespace :release do
  desc "Remove duplicate group memberships"
  task rm_dup_memberships: :environment do
    user_groups = GroupMembership.all.group(:user_id, :group_id).count.select{ |k,v| k if v > 1 }.keys
    user_groups.each do |ug|
      first = true
      GroupMembership.where(user_id: ug[0]).where(group_id: ug[1]).each do |gm|
        gm.destroy unless first
        first = false
      end
    end
  end
end
