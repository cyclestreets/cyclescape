# == Schema Information
#
# Table name: group_membership_requests
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  group_id       :integer          not null
#  status         :string(255)      not null
#  actioned_by_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  message        :text
#
# Indexes
#
#  index_group_membership_requests_on_group_id  (group_id)
#  index_group_membership_requests_on_user_id   (user_id)
#

FactoryGirl.define do
  factory :group_membership_request do
    factory :pending_gmr do
      group
      user
    end

    factory :meg_joining_quahogcc do
      association :user, factory: :meg
      association :group, factory: :quahogcc
    end
  end
end
