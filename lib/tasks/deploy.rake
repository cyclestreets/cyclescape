# frozen_string_literal: true

namespace :deploy do
  desc "Set committee members to be auto subscribed to group threads"
  task committee_admin_subscribe: :environment do
    UserPref.where(user_id: GroupMembership.committee.pluck(:user_id).uniq).update_all(involve_my_groups_admin: true)
  end
end
